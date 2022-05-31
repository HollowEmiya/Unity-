// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/NewSurfaceShader"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            /* ����Unity  vert�����ǣ���������ɫ�����Ĵ��� 
                          frag�����ǣ���ƬԪ��ɫ�����Ĵ��� */
            #pragma vertex vert
            #pragma fragment frag
            
            // application to vertex
            struct a2v {
                // POSITION ����Unity����ģ�Ϳռ�Ķ����������vertex����
                float4 vertex : POSITION;
                // NORMAL : ��ģ�Ϳռ�ķ��߷������ normal ����
                float3 normal : NORMAL;
                // TEXCOORD0 : ��ģ�͵ĵ�һ�������������texcoord
                // �м���Ŷ����β����
                float4 texcoord : TEXCOORD0;
            };
            // vertex to fragment
            struct v2f {
                // SV_POSITION : pos���������ڲü��ռ��λ����Ϣ
                float4 pos : SV_POSITION;
                // COLOR0 : �洢��ɫ��Ϣ (COLOR��
                fixed3 color : COLOR0;
            };
            
            /*---------- 
                ������ɫ�����𶥵���У�
                v��������λ�ã�ͨ��POSITION����ָ��
                POSITION �� SV_POSITION ����CG/HLSL �����壬����ʡ��
                POSITION ���� Unity����ģ�͵Ķ���������䵽����v
                SV_POSITION ���� Unity �Ѷ�����ɫ���� ����ǲü��ռ�Ķ�������
                UnityObjectToClipPos(v) : mul(UNITY_MATRIX_MVP,v)
            */
            /*
            float4 vert(a2v v) : SV_POSITION {
            return UnityObjectToClipPos(v.vertex);
            }
            ----------------------------------*/

            /*
                v2f �� vertex shader
            */
            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
                return o;
            }
            /* ---------------------------
                ��� frag ����û�����룬 ���һ�� fixed4
                SV_TargetҲ�� HLSL�����壬������Ⱦ����
                    ���û������ɫ����һ����ȾĿ���У����������Ĭ��֡������
                ���ص�fixed4������RGBA( red, green, blue, alpha ) alpha��ʾ��ɫ͸����
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
