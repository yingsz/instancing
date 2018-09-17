Shader "Custom/CutOffSwing" {
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
		_TimeScale("Time Scale", Range(0,5)) = 1
		_SwingY( "_SwingY", Range(0,5) )  = 0
		_Cutoff("Alpha cutoff", Range(0,1)) = 0.5
	}

		SubShader{
		Cull Off
		Tags{ "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }
		LOD 200

		CGPROGRAM
#pragma surface surf Lambert vertex:vert noforwardadd alphatest:_Cutoff addshadow

		sampler2D _MainTex;
	half _TimeScale;
	fixed4 _Color;
	half _SwingY;
	struct Input {
		float2 uv_MainTex;
	};

	void vert(inout appdata_full v, out Input o)
	{
		UNITY_INITIALIZE_OUTPUT(Input, o);
		float4 offset = float4(0, 0, 0, 0);
		offset.x = sin(3.1416 * _Time.y * clamp(v.texcoord.y-_SwingY, 0, 1))  * _TimeScale;
		v.vertex += offset;
	}

	void surf(Input IN, inout SurfaceOutput o) {
		fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
		o.Albedo = c.rgb;
		o.Alpha = c.a;
	}
	ENDCG
	}
}
