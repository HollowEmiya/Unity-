// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

/*
    * SHADOW_COORDS,TRANSFER_SHADOW,SHADOW_ATTENUATION we must use when we want to creat shadow
    * we can find their define in AutoLight.cginc
    * SHADOW_COORDS is define texture 
    * TRANSFER_SHADOW is compute texture
    * SHADOW_ATTENUATION is tex2D texture  采样阴影纹理
*/


Shader "Custom/AttenuationAndShadowUseBuildInFunctions"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        //_MainTex ("Main Tex", 2D) = "white" {}
        _Specular("Specular",Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0,256)) = 200
        
    }
    SubShader
    {
        Tags{"RenderType"="Opaque"}
        Pass{
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
               
            #pragma vertex vert
            #pragma fragment frag
            
            // 保证光照衰减等正确赋值
            #pragma multi_compile_fwdbase       
            
            // Shadow
            #include "AutoLight.cginc"            

            #include "Lighting.cginc"

            fixed4 _Diffuse;
            //sampler2D _MainTex;
            //float4 _MainTex_ST;
            fixed3 _Specular;
            float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                 
            };

            struct v2f{ 
                float4 pos : SV_POSITION;
                
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                SHADOW_COORDS(2)                // 宏,声明一个用于对阴影纹理采样的坐标
                // 这宏的参数需要是下一个可用的插值寄存器的索引值，这里就应该是2
            };
                
            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                
                TRANSFER_SHADOW(o);     // compute SHADOW_COORDS in v2f what we defined

                return o;
            }
            
            fixed3 frag(v2f i) : SV_Target{
                // !!! ambient only once!!!!! 环境光只计算一次！！！！！！
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //fixed3 albedo = tex2D(_MainTex,
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
                
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 halfDir = normalize(worldLightDir+viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir,worldLightDir)),_Gloss);
                
                //fixed atten = 1.0;
                // fixed shadow = SHADOW_ATTENUATION(i);
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);    // no need to define atten ,because UNITY_LIGHT_ATTENUATION will help us do that

                return fixed4(ambient+(diffuse+specular)*atten,1.0);
            }

            ENDCG
        }

        Pass{
            Tags{"LightMode"="ForwardAdd"}
               
            Blend One One
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile_fwdadd
            #pragma multi_compile_fwdadd_fullshadows

            #include "Lighting.cginc"
            #include "AutoLight.cginc"            
            
            fixed4 _Diffuse;
            //sampler2D _MainTex;
            //float4 _MainTex_ST;
            fixed3 _Specular;
            float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                 
            };

            struct v2f{ 
                float4 pos : SV_POSITION;
                
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };
                
            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                
                return o;
            }
            
            fixed3 frag(v2f i) : SV_Target{
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                    //fixed atten = 1.0;
                #else
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                    //float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos,1)).xyz;
                    // use texture to find attent
                    //fixed atten = tex2D(_LightTexture0, dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
                #endif
                
                //fixed3 albedo = tex2D(_MainTex,
                fixed3 worldNormal = normalize(i.worldNormal);
                //fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
                
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 halfDir = normalize(worldLightDir+viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir,worldLightDir)),_Gloss);
                
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                
                return fixed4((diffuse+specular)*atten,1.0);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
