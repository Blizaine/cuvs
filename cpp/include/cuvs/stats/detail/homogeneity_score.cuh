/*
 * Copyright (c) 2019-2023, NVIDIA CORPORATION.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * @file homogeneity_score.cuh
 *
 * @brief A clustering result satisfies homogeneity if all of its clusters
 * contain only data points which are members of a single class.
 */

#pragma once

#include <raft/stats/entropy.cuh>
#include <raft/stats/mutual_info_score.cuh>

namespace raft {
namespace stats {
namespace detail {
/**
 * @brief Function to calculate the homogeneity score between two clusters
 * <a href="https://en.wikipedia.org/wiki/Homogeneity_(statistics)">more info on mutual
 * information</a>
 * @param truthClusterArray: the array of truth classes of type T
 * @param predClusterArray: the array of predicted classes of type T
 * @param size: the size of the data points of type int
 * @param lowerLabelRange: the lower bound of the range of labels
 * @param upperLabelRange: the upper bound of the range of labels
 * @param stream: the cudaStream object
 */
template <typename T>
double homogeneity_score(const T* truthClusterArray,
                         const T* predClusterArray,
                         int size,
                         T lowerLabelRange,
                         T upperLabelRange,
                         cudaStream_t stream)
{
  if (size == 0) return 1.0;

  double computedMI, computedEntropy;

  computedMI = raft::stats::mutual_info_score(
    truthClusterArray, predClusterArray, size, lowerLabelRange, upperLabelRange, stream);
  computedEntropy =
    raft::stats::entropy(truthClusterArray, size, lowerLabelRange, upperLabelRange, stream);

  double homogeneity;

  if (computedEntropy) {
    homogeneity = computedMI / computedEntropy;
  } else
    homogeneity = 1.0;

  return homogeneity;
}

};  // end namespace detail
};  // end namespace stats
};  // end namespace raft
