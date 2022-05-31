// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/NewSurfaceShader"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            /* 告诉Unity  vert函数是：“顶点着色器”的代码 
                          frag函数是：“片元着色器”的代码 */
            #pragma vertex vert
            #pragma fragment frag
            
            // application to vertex
            struct a2v {
                // POSITION 告诉Unity：用模型空间的顶点坐标填充vertex变量
                float4 vertex : POSITION;
                // NORMAL : 用模型空间的法线方向填充 normal 坐标
                float3 normal : NORMAL;
                // TEXCOORD0 : 用模型的第一套纹理坐标填充texcoord
                // 中间是哦，结尾是零
                float4 texcoord : TEXCOORD0;
            };
            // vertex to fragment
            struct v2f {
                // SV_POSITION : pos包含定点在裁剪空间的位置信息
                float4 pos : SV_POSITION;
                // COLOR0 : 存储颜色信息 (COLOR零
                fixed3 color : COLOR0;
            };
            
            /*---------- 
                顶点着色器，逐顶点进行，
                v包括顶点位置，通过POSITION语义指定
                POSITION 和 SV_POSITION 都是CG/HLSL 的语义，不可省略
                POSITION 告诉 Unity：把模型的顶点坐标填充到参数v
                SV_POSITION 告诉 Unity 把顶点着色器的 输出是裁剪空间的顶点坐标
                UnityObjectToClipPos(v) : mul(UNITY_MATRIX_MVP,v)
            */
            /*
            float4 vert(a2v v) : SV_POSITION {
            return UnityObjectToClipPos(v.vertex);
            }
            ----------------------------------*/

            /*
                v2f 的 vertex shader
            */
            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
                return o;
            }
            /* ---------------------------
                这个 frag 函数没有输入， 输出一个 fixed4
                SV_Target也是 HLSL的语义，告诉渲染器，
                    把用户输出颜色存在一个渲染目标中，这里输出到默认帧缓存中
                返回的fixed4，采用RGBA( red, green, blue, alpha ) alpha表示颜色透明度
            */
            /*
            fixed4 frag() : SV_Target{
                return fixed4( 0.92, 0.85, 0.0, 0.0);
            }
            -----------------------------*/
            /*
                v2f fragment
            */
            fixed4 frag(v2f i) : SV_Target{
                return fixed4(i.color,0);
            }
            ENDCG
        }
    }
}
