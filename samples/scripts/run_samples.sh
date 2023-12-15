#!/bin/bash -e

# SPDX-FileCopyrightText: Copyright (c) 2022-2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Usage: run_samples.sh
# Runs each sample of CV-CUDA one by one. Some are Python samples and some are C++.
# NOTE: This script may take a long time to finish since some samples may need to create
#	    TensorRT models as they run for the first time.

# Crop and Resize Sample
# Batch size 2
LD_LIBRARY_PATH=./lib ./bin/nvcv_samples_cropandresize -i ./assets/images/ -b 2
export CUDA_MODULE_LOADING="LAZY"

# Run the classification Python sample first. This will save the necessary TensorRT model
# and labels in the output directory. The C++ sample can then use those directly.
# Run the segmentation Python sample with default settings, without any command-line args.
find /tmp/ -maxdepth 1 -type f -delete
python3 ./classification/python/main.py
# Run it on a specific image with batch size 1 with PyTorch backend.
python3 ./classification/python/main.py -i ./assets/images/tabby_tiger_cat.jpg -b 1 -bk pytorch
# # Run it on a specific image with batch size 4 with PyTorch backend. Uses Same image multiple times
python3 ./classification/python/main.py -i ./assets/images/tabby_tiger_cat.jpg -b 4 -bk pytorch
# Run it on a folder worth of images with batch size 2 with PyTorch backend.
python3 ./classification/python/main.py -i ./assets/images/ -b 2 -bk pytorch
# Run it on a specific image with batch size 1 with TensorRT backend with saving the output in a specific directory.
mkdir /tmp/classification
python3 ./classification/python/main.py -i ./assets/images/tabby_tiger_cat.jpg -b 1 -bk tensorrt -o /tmp/classification
# Run it on a specific image with batch size 1 with TensorRT backend with saving the output in a specific directory.
python3 ./classification/python/main.py -i ./assets/images/tabby_tiger_cat.jpg -b 2 -bk tensorrt -o /tmp/classification
# Run it on a video with batch size 1 with TensorRT backend with saving the output in a specific directory.
python3 ./classification/python/main.py -i ./assets/videos/pexels-ilimdar-avgezer-7081456.mp4 -b 1 -bk tensorrt -o /tmp/classification
# Run the classification C++ sample. Since the Python sample was already run, we can reuse the TensorRT model
# and the labels file generated by it.
# Batch size 1
LD_LIBRARY_PATH=./lib ./bin/nvcv_samples_classification -e /tmp/classification/model.1.224.224.trtmodel -i ./assets/images/tabby_tiger_cat.jpg -l /tmp/classification/labels.txt -b 1
# Batch size 2
LD_LIBRARY_PATH=./lib ./bin/nvcv_samples_classification -e /tmp/classification/model.2.224.224.trtmodel -i ./assets/images/tabby_tiger_cat.jpg -l /tmp/classification/labels.txt -b 2


# Run the segmentation Python sample with default settings, without any command-line args.
find /tmp/ -maxdepth 1 -type f -delete
python3 ./segmentation/python/main.py
# Run the segmentation sample with default settings for PyTorch backend.
python3 ./segmentation/python/main.py -bk pytorch
# Run it on a single image with high batch size for the background class writing to a specific directory with PyTorch backend
python3 ./segmentation/python/main.py -i ./assets/images/tabby_tiger_cat.jpg -o /tmp -b 5 -c __background__ -bk pytorch
# Run it on a folder worth of images with the default tensorrt backend
python3 ./segmentation/python/main.py -i ./assets/images/ -o /tmp -b 4 -c __background__
# Run it on a folder worth of images with PyTorch
python3 ./segmentation/python/main.py -i ./assets/images/ -o /tmp -b 5 -c __background__ -bk pytorch
# Run on a single image with custom resized input given to the sample for the dog class
python3 ./segmentation/python/main.py -i ./assets/images/Weimaraner.jpg -o /tmp -b 1 -c dog -th 512 -tw 512
# Run it on a video for class background.
python ./segmentation/python/main.py -i ./assets/videos/pexels-ilimdar-avgezer-7081456.mp4 -b 4 -c __background__
# Run it on a video for class background with the PyTorch backend.
python ./segmentation/python/main.py -i ./assets/videos/pexels-ilimdar-avgezer-7081456.mp4 -b 4 -c __background__ -bk pytorch

# Run the object detection Python sample with default settings, without any command-line args.
find /tmp/ -maxdepth 1 -type f -delete
python3 ./object_detection/python/main.py
# Run it with batch size 1 on a single image
python3 ./object_detection/python/main.py -i ./assets/images/peoplenet.jpg  -b 1
# Run it with batch size 4 on a video
python3 ./object_detection/python/main.py -i ./assets/videos/pexels-chiel-slotman-4423925-1920x1080-25fps.mp4 -b 4
# Run it with batch size 2 on a folder of images
python3 ./object_detection/python/main.py -i ./assets/images/ -b 3
# RUn it with the TensorFlow backend
python3 ./object_detection/python/main.py -i ./assets/videos/pexels-chiel-slotman-4423925-1920x1080-25fps.mp4 -b 4 -bk tensorflow

# Run the label Python sample with default settings, without any command-line args.
find /tmp/ -maxdepth 1 -type f -delete
python3 ./label/python/main.py
# Run it with batch size 1 on a single image
python3 ./label/python/main.py -i ./assets/images/peoplenet.jpg  -b 1
