using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SameMatDifferentObjectScript : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
	{
		MaterialPropertyBlock propertyBlock = new MaterialPropertyBlock();
		GetComponent<Renderer>().GetPropertyBlock(propertyBlock);
		propertyBlock.SetColor("_Color", new Color(0.5f, 0, 0, 1));
		GetComponent<Renderer>().SetPropertyBlock(propertyBlock);

	}

	// Update is called once per frame
	void Update()
	{

	}
}
