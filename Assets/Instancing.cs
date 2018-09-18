using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Instancing : MonoBehaviour {
    private Mesh mesh;
    private Material mat;
    private Matrix4x4[] matrices;
    // Use this for initialization
    private Vector4[] lightmapOffSet;
	void Start () {
        mesh = GetComponent<MeshFilter>().mesh;
        mat = GetComponent<MeshRenderer>().sharedMaterial;
        mat.enableInstancing = true;
        lightmapOffSet = new Vector4[1023]; 
         matrices = new Matrix4x4[1023];
        for (int i = 0; i < matrices.Length; i++)
        {
            var position = Random.insideUnitSphere * 10;
            var rotation = Quaternion.LookRotation(Random.insideUnitSphere);
            var scale = Vector3.one * Random.Range(-2f, 2f);
            var matrix = Matrix4x4.TRS(position, rotation, scale);
            matrices[i] = matrix;
            lightmapOffSet[i] = new Vector4(0.4f, 0.4f, 0.4f, 0);
        }
        mat.SetVectorArray("LightMapOffSets", lightmapOffSet);
        //var offset = GetComponent<MeshRenderer>().lightmapScaleOffset;
        //Debug.Log(offset);
    }

    // Update is called once per frame
    void Update () {
        Graphics.DrawMeshInstanced(mesh, 0, mat, matrices);
	}
}