Shader "Unity Shader Book/Chapter9/BumpedSpecularShader On Light"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpTex("Bump Tex", 2D) = "bump"{}
        _BumpScale("Bump Scale", Float) = 1.0
        _SpecularTex("Specular Tex", 2D) = "white"{}
        _SpecularScale("Specular Scale", Float) = 1.0
        _Gloss ("Gloss", Range(8,256)) = 20
        _Specular ("Specular Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags{"RenderType"="Opaque" "Queue"="Geometry"}
        Pass{
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag  
            #pragma multi_compile_fwdbase
            
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed3 _Diffuse;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpTex;
            //float4 _BumpTex_ST;
            float _BumpScale;
            sampler2D _SpecularTex;
            //float4 _SpecularTex_ST;
            float _SpecularScale;
            float _Gloss;
            fixed3 _Specular;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };        

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
                SHADOW_COORDS(4)
            };
            
            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy =  v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                
                TANGENT_SPACE_ROTATION;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldBiNormal = cross(worldNormal,worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x, worldBiNormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBiNormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBiNormal.z, worldNormal.z, worldPos.z);
                
                TRANSFER_SHADOW(o);
                return o;
            }
            
            fixed3 frag(v2f i) : SV_Target{
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                
                fixed3 bump = UnpackNormal(tex2D(_BumpTex,i.uv.xy));
                bump.xy *= _BumpScale;
                bump.z = sqrt(1.0-saturate(dot(bump.xy,bump.xy)));
                bump = normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));

                fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb * _Diffuse.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));

                fixed3 halfDir = normalize(viewDir + lightDir);
                fixed specularMask = tex2D(_SpecularTex,i.uv.xy).r * _SpecularScale;
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(bump,halfDir)),_Gloss) * specularMask;

                UNITY_LIGHT_ATTENUATION(atten,i,worldPos);                
                return fixed4(ambient+ (diffuse+specular)*atten , 1.0);
            }
            
            ENDCG
        }
        
        Pass{
            Tags{"LightMode"="ForwardAdd"}
            
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag  
            #pragma multi_compile_fwdbase
            
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed3 _Diffuse;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpTex;
            //float4 _BumpTex_ST;
            float _BumpScale;
            sampler2D _SpecularTex;
            //float4 _SpecularTex_ST;
            float _SpecularScale;
            float _Gloss;
            fixed3 _Specular;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };        

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
                SHADOW_COORDS(4)
            };
            
            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy =  v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                
                TANGENT_SPACE_ROTATION;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldBiNormal = cross(worldNormal,worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x, worldBiNormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBiNormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBiNormal.z, worldNormal.z, worldPos.z);
                
                TRANSFER_SHADOW(o);
                return o;
            }
            
            fixed3 frag(v2f i) : SV_Target{
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                #else
                    fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz - worldPos);
                #endif
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                
                fixed3 bump = UnpackNormal(tex2D(_BumpTex,i.uv.xy));
                bump.xy *= _BumpScale;
                bump.z = sqrt(1.0-saturate(dot(bump.xy,bump.xy)));
                bump = normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));

                fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb * _Diffuse.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));

                fixed3 halfDir = normalize(viewDir + lightDir);
                fixed specularMask = tex2D(_SpecularTex,i.uv.xy).r * _SpecularScale;
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(bump,halfDir)),_Gloss) * specularMask;

                UNITY_LIGHT_ATTENUATION(atten,i,worldPos);                
                return fixed4((diffuse+specular)*atten , 1.0);
            }
            
            ENDCG
        }
    }
    FallBack "Diffuse"
}
