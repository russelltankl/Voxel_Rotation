// TestMatrix.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include "FloatVector.h"
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

#define PI 3.14159265
using namespace std;

// Multiply a 3 x 3 Matrix size
void multiply3x3(Float3 *firstMat, Float3 *secondMat, Float3 *outputMat)
{
	int i, j, k;
	for (i = 0; i < 3; i++)
	{
		for (j = 0; j < 3; j++)
		{
			for (k = 0; k < 3; k++)
				outputMat[j].value[i] += firstMat[k].value[i] * secondMat[j].value[k];
		}
	}
	cout << "Printing a 3 x 3 Matrix: " << endl;
	for (i = 0; i < 3; i++) {
		for (j = 0; j < 3; j++) {
			cout << outputMat[j].value[i] << " ";
		}
		cout << endl;
	}
	cout << endl;
}

// Multiply a 4 x 4 Matrix size
void multiply4x4(Float4 *firstMat, Float4 *secondMat, Float4 *outputMat)
{
	int i, j, k;
	for (i = 0; i < 4; i++)
	{
		for (j = 0; j < 4; j++)
		{
			for (k = 0; k < 4; k++)
				outputMat[j].value[i] += firstMat[k].value[i] * secondMat[j].value[k];
		}
	}
	//cout << "Printing a 4 x 4 Matrix: " << endl;
	//for (i = 0; i < 4; i++) {
	//	for (j = 0; j < 4; j++) {
	//		cout << outputMat[j].value[i] << " ";
	//	}
	//	cout << endl;
	//}
	//cout << endl;
}

// Multiply a n x m Matrix size, where you can define N and M
void multiplynxm(Float4 *firstMat, Float4 *secondMat, Float4 *outputMat, int N, int M)
{
	int i, j, k;
	for (i = 0; i < N; i++)
	{
		for (j = 0; j < M; j++)
		{
			for (k = 0; k < N; k++)
				outputMat[j].value[i] += firstMat[k].value[i] * secondMat[j].value[k];
		}
	}
	//cout << "Transformation Matrix X Location Matrix: " << endl;
	//for (i = 0; i < N; i++) {
	//	for (j = 0; j < M; j++) {
	//		cout << outputMat[j].value[i] << " ";
	//	}
	//	cout << endl;
	//}
	//cout << endl;
}

// Generate a 3 x 3 Transformation Matrix, where you input the rotation axis, coordinate and angle of rotation
Float3 *gen3x3tm(float x, float y, float theta)
{
	Float3 *a = new Float3[3]();
	Float3 *b = new Float3[3]();
	Float3 *c = new Float3[3]();
	Float3 *result1 = new Float3[3];
	Float3 *result2 = new Float3[3];


	a[0].value[0] = 1;
	a[1].value[1] = 1;
	a[2].value[0] = x;
	a[2].value[1] = y;
	a[2].value[2] = 1;

	b[0].value[0] = 1;
	b[1].value[1] = 1;
	b[2].value[0] = -x;
	b[2].value[1] = -y;
	b[2].value[2] = 1;

	c[0].value[0] = floor(cos(theta*PI / 180));
	c[0].value[1] = floor(sin(theta*PI / 180));
	c[1].value[0] = floor(-sin(theta*PI / 180));
	c[1].value[1] = floor(cos(theta*PI / 180));
	c[2].value[2] = 1;

	multiply3x3(a, c, result1);
	multiply3x3(result1, b, result2);
	delete[](a);
	delete[](b);
	delete[](c);
	delete[](result1);

	return result2;
}

// Generate a 4 x 4 Transformation Matrix, where you input the rotation axis, coordinate and angle of rotation
Float4 *gen4x4tm(float xCoor, float yCoor, float zCoor, char axis, float theta)
{
	Float4 *a = new Float4[4]();
	Float4 *b = new Float4[4]();
	Float4 *c = new Float4[4]();
	Float4 *result1 = new Float4[4];
	Float4 *result2 = new Float4[4];

	a[0].value[0] = 1;
	a[1].value[1] = 1;
	a[2].value[2] = 1;
	a[3].value[0] = xCoor;
	a[3].value[1] = yCoor;
	a[3].value[2] = zCoor;
	a[3].value[3] = 1;

	b[0].value[0] = 1;
	b[1].value[1] = 1;
	b[2].value[2] = 1;
	b[3].value[3] = 1;

	c[3].value[3] = 1;

	// TEMPORARY FIX
	int OddEven = 1;
	if (OddEven == 1)
	{
		float Divisable = 32.0 / 2.0; //16
		float Divisable1 = Divisable - 1.0; //15

		if (axis == 'x')
		{
			c[0].value[0] = 1;
			c[1].value[1] = floor(cos(theta*PI / 180));
			c[1].value[2] = floor(sin(theta*PI / 180));
			c[2].value[1] = floor(-sin(theta*PI / 180));
			c[2].value[2] = floor(cos(theta*PI / 180));

			if (zCoor == Divisable1) // 15
			{
				if (yCoor == Divisable1) // 15
				{
					b[3].value[0] = -xCoor;
					b[3].value[1] = -yCoor;
					b[3].value[2] = -zCoor - 1;
				}
				else if (yCoor == Divisable) // 16
				{
					b[3].value[0] = -xCoor;
					b[3].value[1] = -yCoor + 1;
					b[3].value[2] = -zCoor;
				}
			}
			else if (zCoor == Divisable) // 16
			{
				if (yCoor == Divisable1) // 15
				{
					b[3].value[0] = -xCoor;
					b[3].value[1] = -yCoor - 1;
					b[3].value[2] = -zCoor;
				}
				else if (yCoor == Divisable) // 16
				{
					b[3].value[0] = -xCoor;
					b[3].value[1] = -yCoor;
					b[3].value[2] = -zCoor + 1;
				}
			}
		}
		else if (axis == 'y')
		{
			c[1].value[1] = 1;
			c[0].value[0] = floor(cos(theta*PI / 180));
			c[0].value[2] = floor(-sin(theta*PI / 180));
			c[2].value[0] = floor(sin(theta*PI / 180));
			c[2].value[2] = floor(cos(theta*PI / 180));

			if (xCoor == Divisable1) // 15
			{
				if (zCoor == Divisable1) // 15
				{
					b[3].value[0] = -xCoor - 1;
					b[3].value[1] = -yCoor;
					b[3].value[2] = -zCoor;
				}
				else if (zCoor == Divisable) // 16
				{
					b[3].value[0] = -xCoor;
					b[3].value[1] = -yCoor;
					b[3].value[2] = -zCoor + 1;
				}
			}
			else if (xCoor == Divisable) // 16
			{
				if (zCoor == Divisable1) // 15
				{
					b[3].value[0] = -xCoor;
					b[3].value[1] = -yCoor;
					b[3].value[2] = -zCoor - 1;
				}
				else if (zCoor == Divisable) // 16
				{
					b[3].value[0] = -xCoor + 1;
					b[3].value[1] = -yCoor;
					b[3].value[2] = -zCoor;
				}
			}
		}
		else if (axis == 'z')
		{
			c[2].value[2] = 1;
			c[0].value[0] = floor(cos(theta*PI / 180));
			c[0].value[1] = floor(sin(theta*PI / 180));
			c[1].value[0] = floor(-sin(theta*PI / 180));
			c[1].value[1] = floor(cos(theta*PI / 180));

			if (xCoor == Divisable1) // 15
			{
				if (yCoor == Divisable1) // 15
				{
					b[3].value[0] = -xCoor;
					b[3].value[1] = -yCoor - 1;
					b[3].value[2] = -zCoor;
				}
				else if (yCoor == Divisable) // 16
				{
					b[3].value[0] = -xCoor - 1;
					b[3].value[1] = -yCoor;
					b[3].value[2] = -zCoor;
				}
			}
			else if (xCoor == Divisable) // 16
			{
				if (yCoor == Divisable1) // 15
				{
					b[3].value[0] = -xCoor + 1;
					b[3].value[1] = -yCoor;
					b[3].value[2] = -zCoor;
				}
				else if (yCoor == Divisable) // 16
				{
					b[3].value[0] = -xCoor;
					b[3].value[1] = -yCoor + 1;
					b[3].value[2] = -zCoor;
				}
			}
		}
	}

	cout << "Translation Matrix X Rotation Matrix: ";
	cout << endl;
	multiply4x4(a, c, result1);
	cout << "Rotation Matrix X Translation Matrix: ";
	cout << endl;
	multiply4x4(result1, b, result2);
	delete[](a);
	delete[](b);
	delete[](c);
	delete[](result1);
	return result2;
}

class Matrix
{
public:
	int numDivX = 32;
	int numDivY = 32;
	int numDivZ = 32;
	int voxelDataSize = numDivX * numDivY * numDivZ;
	float *voxelValue;
	float *TvoxelValue;
	Float4 *Coor;
	const char *fName = "toilet_0444.raw"; // Input .raw file
	void read();
	void save();
	void rotate(int xDist, int yDist, int zDist, char rotateAxis, int thetas);
};

// Reads .raw file & create corresponding coordinate matrix for voxels
void Matrix::read()
{
	size_t size = voxelDataSize*sizeof(float);

	FILE *fp = fopen(fName, "rb");

	if (!fp)
	{
		fprintf(stderr, "Error opening file '%s'\n", fName);
		abort();
	}

	unsigned char *tempdata = new unsigned char[voxelDataSize];
	size_t read = fread(tempdata, sizeof(unsigned char), voxelDataSize, fp);
	fclose(fp);
	printf("Read '%s', %d bytes\n", fName, read);
	this->voxelValue = new float[voxelDataSize];
	for (int k = 0; k < voxelDataSize; k++)
	{
		this->voxelValue[k] = float(ceil(tempdata[k] / 254));
		//cout << voxelValue[k] << " " << endl;
	}

	this->Coor = new Float4[voxelDataSize];
	for (int i = 0; i < numDivZ; i++)
	{
		for (int j = 0; j < numDivY; j++)
		{
			for (int k = 0; k < numDivX; k++)
			{
				int marker = (numDivZ*numDivZ*i) + (numDivY*j) + k;
				Coor[marker].value[0] = k;
				Coor[marker].value[1] = j;
				Coor[marker].value[2] = i;
				Coor[marker].value[3] = 1;
			}
		}
	}
	delete[] tempdata;

	//cout << "Original voxel values: " << endl;
	//for (int p = 0; p < voxelDataSize; p++)
	//{
	//	cout << voxelValue[p] << " ";
	//}
	//cout << endl;
}

// Perform complete voxel rotation in 3D space
void Matrix::rotate(int xDist, int yDist, int zDist, char rotateAxis, int thetas)
{
	Float4 *Transformed = new Float4[voxelDataSize]; // Final transformed matrix stored here
	TvoxelValue = new float[voxelDataSize]; // Final voxel value stored here
	Float4 *TransMat = gen4x4tm(xDist, yDist, zDist, rotateAxis, thetas); // Obtain transformation matrix
	multiplynxm(TransMat, Coor, Transformed, 4, voxelDataSize); // matrix multiply to get Transformed
	for (int fin = 0; fin < voxelDataSize; fin++) // rotate voxelsx
	{
		int yes = (Transformed[fin].value[2] * numDivZ * numDivZ) + (Transformed[fin].value[1] * numDivY) + Transformed[fin].value[0];
		this->TvoxelValue[yes] = voxelValue[fin];
	}
	delete[](Transformed);
	delete[](TransMat);

	//cout << "Transformed voxel values: " << endl;
	//for (int p = 0; p < voxelDataSize; p++)
	//{
	//	cout << TvoxelValue[p] << " ";
	//}
	//cout << endl;
}

// Saves rotated voxels back into raw file
void Matrix::save()
{
	ofstream rawFile;
	string fName = "phi_grid.raw";
	rawFile.open(fName, std::ofstream::binary);
	if (!rawFile.good())
	{
		cerr << "Unable to open output file for writing" << endl;
		abort();
	}
	char* phiOut = new char[voxelDataSize];
	for (int k = 0; k < voxelDataSize; k++)
	{
		//if (GPU)
		//	phiOut[k] = char(phiValGPU[k] * 255);
		//else
		phiOut[k] = char(TvoxelValue[k] * 255);
	}
	rawFile.write((char*)phiOut, voxelDataSize*sizeof(char));
	delete[] phiOut;
	rawFile.close();
	cout << "Voxel File Saved as : " << fName << endl << endl;
}

class Artificial
{
public:
	Float4 *place;
	int Xs = 3;
	int Ys = 3;
	int Zs = 3;
	int vSize = Xs * Ys * Zs;
	float *voxValue;
	float *TransformedVox;

	void address();
	void save();
	void rotate(int xDist, int yDist, int zDist, char rotateAxis, int thetas);
};


void Artificial::address()
{
	this->voxValue = new float[vSize]();
	// assign voxel value
	voxValue[0] = 1;
	voxValue[4] = 1;
	voxValue[5] = 1;
	voxValue[7] = 1;
	voxValue[13] = 1;
	voxValue[14] = 1;
	voxValue[16] = 1;
	voxValue[17] = 1;
	voxValue[22] = 1;


	cout << "Initialized voxel values: " << endl;
	for (int p = 0; p < vSize; p++)
	{
		cout << voxValue[p] << " ";
	}
	cout << endl;


	this->place = new Float4[vSize];
	for (int i = 0; i < Zs; i++)
	{
		for (int j = 0; j < Ys; j++)
		{
			for (int k = 0; k < Xs; k++)
			{
				int marker = (Zs*Zs*i) + (Ys*j) + k;
				place[marker].value[0] = k;
				place[marker].value[1] = j;
				place[marker].value[2] = i;
				place[marker].value[3] = 1;
			}
		}
	}
	cout << "Initial Location Matrix: " << endl;
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < vSize; j++) {
			cout << place[j].value[i] << " ";
		}
		cout << endl;
	}
	cout << endl;
}

void Artificial::rotate(int xDist, int yDist, int zDist, char rotateAxis, int thetas)
{
	Float4 *FinalT = new Float4[4]; // Final transformed matrix stored here
	TransformedVox = new float[vSize]; // Final voxel value stored here
	Float4 *TMat = gen4x4tm(xDist, yDist, zDist, rotateAxis, thetas); // Obtain transformation matrix
	multiplynxm(TMat, place, FinalT, 4, vSize); // matrix multiply to get Transformed
	for (int fin = 0; fin < vSize; fin++) // rotate voxels
	{
		int yes = (FinalT[fin].value[2] * Zs * Zs) + (FinalT[fin].value[1] * Ys) + FinalT[fin].value[0];
		this->TransformedVox[yes] = voxValue[fin];
	}
	delete[](FinalT);
	delete[](TMat);
	cout << "Transformed voxel values: " << endl;
	for (int p = 0; p < vSize; p++)
	{
		cout << TransformedVox[p] << " ";
	}
	cout << endl;
}

void Artificial::save()
{
	ofstream rawFile;
	string fName = "aiyo.raw";
	rawFile.open(fName, std::ofstream::binary);
	if (!rawFile.good())
	{
		cerr << "Unable to open output file for writing" << endl;
		abort();
	}
	char* phiOut = new char[vSize];
	for (int k = 0; k < vSize; k++)
	{
		//if (GPU)
		//	phiOut[k] = outputPhi(phiValGPU[k] * 255);
		//else
		//phiOut[k] = char(TransformedVox[k] * 255);
		phiOut[k] = char(voxValue[k] * 255);
	}
	rawFile.write((char*)phiOut, vSize*sizeof(char));
	delete[] phiOut;
	rawFile.close();
	cout << "Voxel File Saved as : " << fName << endl << endl;
}

int main()
{
	//Matrix wow;
	//wow.read();
	//wow.rotate(16, 16, 16, 'y', 90);
	//wow.save();

	Artificial Testz;
	Testz.address();
	Testz.rotate(1, 1, 1, 'y', 90);
	Testz.save();


	return 0;
}