Shader"Custom/Instancing/CutOffSwing"
{
	Properties{
		_MainTex("MainTex", 2D) = "white"{}
		Lightmap("Lightmap", 2D) = "white"{}
		_MainColor("MainColor", Color) = (1, 1,1,1)
		_TimeScale("TimeScale", Range(0, 10)) = 1
		_SwingY("_SwingY", Range( 0, 1)) = 0
		_Cutoff("_Cutoff", Range(0,1)) = 0.5
	}
	
	SubShader{
		Cull Off
		Tags{"RenderType"="Transparent"}
		LOD 150
		Pass{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_instancing
				#include "UnityCG.cginc"
				
				sampler2D _MainTex;
				half _Cutoff;
				struct v2f{
					V2F_SHADOW_CASTER;
					half2 uv:TEXCOORD1;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};
				v2f vert(appdata_base v)
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID( v );
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					o.uv = v.texcoord.xy;
					TRANSFER_SHADOW_CASTER_NORMALOFFSET( o);
					return o;
				}
				
				fixed4 frag( v2f o ):SV_Target
				{
					clip( tex2D( _MainTex, o.uv ).a-_Cutoff);
					SHADOW_CASTER_FRAGMENT(o)
				}
			ENDCG
		}
			
		Pass{
			Tags{ "LightMode" = "ForwardBase" }
			
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_instancing
				#include "UnityCG.cginc"
				
				sampler2D _MainTex;
				fixed4 _MainColor;
				half _TimeScale;
				half _SwingY;
				half _Cutoff;
				sampler2D Lightmap;
				UNITY_INSTANCING_CBUFFER_START(LightMapOffSets)
					UNITY_DEFINE_INSTANCED_PROP(half4, _OffSet)
				UNITY_INSTANCING_CBUFFER_END
			
				struct v2f{
					float4 pos :SV_POSITION;
					half2 uv :TEXCOORD1;
					half2 lmap:TEXCOORD2;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};
				
				v2f vert( appdata_full v)
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					v.vertex.x += sin(3.1416 * _Time.y * clamp(v.texcoord.y-_SwingY, 0, 1))  * _TimeScale;
					o.pos = UnityObjectToClipPos( v.vertex );
					o.uv = v.texcoord;
					half4 offset = UNITY_ACCESS_INSTANCED_PROP(_OffSet);
					o.lmap = v.texcoord1.xy * offset.xy + offset.zw;
					return o;
				}
				
				fixed4 frag( v2f i ):SV_Target
				{
					UNITY_SETUP_INSTANCE_ID(i);
					fixed4 rgba = tex2D(_MainTex, i.uv)* _MainColor;
					clip( rgba.a - _Cutoff );
					
					fixed4 bakedColorTex = tex2D(Lightmap, i.lmap);
					half3 bakedColor = DecodeLightmap(bakedColorTex);
					
					return rgba * half4( bakedColor, 1.0);
				}
			ENDCG
		}
	}
}