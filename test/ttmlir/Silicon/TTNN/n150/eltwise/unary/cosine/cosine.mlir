// RUN: ttmlir-opt --ttir-to-ttnn-backend-pipeline="system-desc-path=%system_desc_path%" %s > %t.mlir
// RUN: FileCheck %s --input-file=%t.mlir
// RUN: ttmlir-translate --ttnn-to-flatbuffer %t.mlir > %t.ttnn

func.func @cosine(%arg0: tensor<32x32xf32>) -> tensor<32x32xf32> {
  %0 = ttir.empty() : tensor<32x32xf32>
  %1 = "ttir.cos"(%arg0, %0) : (tensor<32x32xf32>, tensor<32x32xf32>) -> tensor<32x32xf32>
  // CHECK: "ttnn.cos"
  // CHECK-SAME: tensor<32x32xf32
  // CHECK-SAME: -> tensor<32x32xf32
  return %1 : tensor<32x32xf32>
}
