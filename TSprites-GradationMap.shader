// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "TSprites/GradationMap"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
        [HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
        _GradationTex("Gradation Texture", 2D) = "white"{}
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma multi_compile _ PIXELSNAP_ON
            #pragma multi_compile _ ETC1_EXTERNAL_ALPHA
            #include "UnitySprites.cginc"

            sampler2D _GradationTex;
            float _val_u;

            struct appdata_ts
            {
            	float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f_ts
            {
            	float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                fixed4 color : COLOR;
                UNITY_VERTEX_OUTPUT_STEREO	
            };

            v2f_ts vert(appdata_ts IN){
            	v2f_ts OUT;
            	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

            	OUT.pos = UnityObjectToClipPos(IN.vertex);
            	OUT.uv0 = IN.texcoord0;

            	#ifdef PIXELSNAP_ON
                OUT.pos = UnityPixelSnap (OUT.pos);
                #endif
                OUT.color = IN.color;
                return OUT;
            }

            fixed4 frag(v2f_ts IN) : SV_Target{
            	// Default
                  fixed4 mainColor = SampleSpriteTexture(IN.uv0);
                  // グラデーションの色を求める
                  float2 gradation_uv = float2(mainColor.r, 0);
                  fixed4 finalColor = tex2D(_GradationTex, gradation_uv);

                  finalColor *= IN.color;
                  float finalAlpha = mainColor.a * finalColor.a;
            	  return fixed4(finalColor.rgb, finalAlpha);
            }
        ENDCG
        }
    }
}
