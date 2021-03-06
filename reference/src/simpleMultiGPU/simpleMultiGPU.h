/*
 * Copyright 1993-2009 NVIDIA Corporation.  All rights reserved.
 *
 * NVIDIA Corporation and its licensors retain all intellectual property and 
 * proprietary rights in and to this software and related documentation. 
 * Any use, reproduction, disclosure, or distribution of this software 
 * and related documentation without an express license agreement from
 * NVIDIA Corporation is strictly prohibited.
 *
 * Please refer to the applicable NVIDIA end user license agreement (EULA) 
 * associated with this source code for terms and conditions that govern 
 * your use of this NVIDIA software.
 * 
 */

/*
 * This application demonstrates how to use the CUDA API to use multiple GPUs.
 *
 * There's one CUDA context per thread. To use multiple CUDA contexts you
 * have to create multiple threads. One for each GPU. For optimal performance,
 * the number of CPU cores should be equal to the number of GPUs in the system.
 *
 * Creating CPU threads has a certain overhead. So, this is only worth when you
 * have a significant amount of work to do per thread. It's also recommended to
 * create a pool of threads and reuse them to avoid this overhead.
 *
 * Note that in order to detect multiple GPUs in your system you have to disable
 * SLI in the nvidia control panel. Otherwise only one GPU is visible to the 
 * application. On the other side, you can still extend your desktop to screens 
 * attached to both GPUs.
 */

#ifndef SIMPLEMULTIGPU_H
#define SIMPLEMULTIGPU_H

typedef struct {
    //Device id
    int device;

    //Host-side input data
    int dataN;
    float *h_Data;

    //Partial sum for this GPU
    float *h_Sum;
} TGPUplan;

extern "C" 
void launch_reduceKernel(float *d_Result, float *d_Input, int N, int BLOCK_N, int THREAD_N);

#endif
