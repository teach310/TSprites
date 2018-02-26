// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "TSprites/Effect"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
        [HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
        // SubTexture
        [Toggle(USE_SUB_TEXTURE)] _UseSubTexture ("Use SubTexture", Float) = 0
        _SubTex("Sub Texture", 2D) = "white"{}
        [Header(Blend)]
        [KeywordEnum(Add, Mix)]
         _SubTexBlend("Blend", Float) = 0
         _SubTexBlendIntensity("Intensity", Range(0,1)) = 1

         _SubTexScrollU("Scroll U", Range(-10, 10)) = 0.3
         _SubTexScrollV("Scroll V", Range(-10, 10)) = 0.3

         // 基本はRGBMask
         [Toggle(USE_MASK)] _UseMask ("Use Mask", Float) = 0
         _MaskTex("Mask", 2D) = "white"{}

         // GradationTex
         [Toggle(USE_GRADATION)] _UseGradation ("Use Mask", Float) = 0
         // Clampにすること
        _GradationTex("Gradation Texture", 2D) = "white"{}


        // Polar Coord
        [Toggle(USE_POLAR_COORD)] _UsePolarCoord ("Use Polar Coord", Float) = 0
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
            #pragma multi_compile _ USE_SUB_TEXTURE
            #pragma multi_compile _ USE_MASK
            #pragma multi_compile _ USE_GRADATION
            #pragma multi_compile _ USE_POLAR_COORD
            #pragma multi_compile _SUBTEXBLEND_ADD _SUBTEXBLEND_MIX
            #include "UnitySprites.cginc"
            #include "TSpritesCG.cginc"
            sampler2D _SubTex;
            float _SubTexBlendIntensity;
            uniform float _SubTexScrollU; uniform float _SubTexScrollV;

            sampler2D _MaskTex;
            sampler2D _GradationTex;


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
                float4 offset : TEXCOORD2;
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
                OUT.offset.xy = _Time.y * -float2(_SubTexScrollU, _SubTexScrollV);
                return OUT;
            }

            fixed4 frag(v2f_ts IN) : SV_Target{
            	float2 mainUV = IN.uv0;
            	#if USE_POLAR_COORD
            	mainUV = ConvertToPolarCoord(IN.uv0);
            	#endif

            	// Default
                fixed4 mainColor = SampleSpriteTexture(mainUV);

                // Mask
                // 基本はrでマスクをかける
                #ifdef USE_MASK
                fixed4 maskCol = tex2D(_MaskTex, IN.uv0);
                mainColor.a *= maskCol.r;
                #endif

                // SubTexture
                #ifdef USE_SUB_TEXTURE
                fixed4 subColor = tex2D(_SubTex, IN.uv0 + IN.offset);
	                // alphaはmain持ち
	                // addかalphaでlerpするか　足し算か
                #ifdef _SUBTEXBLEND_ADD
                	mainColor.rgb += subColor.rgb * _SubTexBlendIntensity;
                #elif _SUBTEXBLEND_MIX
                	mainColor.rgb = lerp(mainColor.rgb, subColor.rgb, subColor.a * _SubTexBlendIntensity);
                #endif
                #endif

                #if USE_GRADATION
//				 グラデーションの色を求める
                float2 gradation_uv = float2(mainColor.r, 0);
                fixed4 gradColor = tex2D(_GradationTex, gradation_uv);
                mainColor.rgb = gradColor.rgb;
                mainColor.a *= gradColor.a;

                #endif
                return mainColor * IN.color;

            }
        ENDCG
        }

    }
    CustomEditor "TSpritesEffectEditor"
}
