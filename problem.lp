Maximize
  - 1 x00010_title_area_canvas_height + 1 x00014_data_area_canvas_height + 1 x00015_data_area_canvas_width - 1 x00018_top_decorations_area_canvas_height - 1 x00027_right_decorations_area_canvas_width - 1 x00034_bottom_decorations_area_canvas_height - 1 x00043_left_decorations_area_canvas_width + 1 x00048_axis_size - 1 x00049_axis_margin_start - 1 x00050_axis_margin_end + 1 x00053_axis_size - 1 x00054_axis_margin_start - 1 x00055_axis_margin_end + 1 x00058_axis_size - 1 x00059_axis_margin_start - 1 x00060_axis_margin_end + 1 x00063_axis_size - 1 x00064_axis_margin_start - 1 x00065_axis_margin_end - 1 x00083_left_axis_canvas_canvas_width - 1 x00086_top_axis_canvas_canvas_height - 1 x00091_right_axis_canvas_canvas_width - 1 x00094_bottom_axis_canvas_canvas_height
Subject To
  c0: - 1 x00000_plot_bounds_top + 1 x00005_plot_area_canvas_y = 0
  c1: - 1 x00002_plot_bounds_left + 1 x00004_plot_area_canvas_x = 0
  c10: - 1 x00013_data_area_canvas_y - 1 x00014_data_area_canvas_height + 1 x00041_left_decorations_area_canvas_y + 1 x00042_left_decorations_area_canvas_height = 0
  c100: - 1 x00025_right_decorations_area_canvas_y + 1 x00089_right_axis_canvas_canvas_y = 0
  c101: - 1 x00024_right_decorations_area_canvas_x + 1 x00066_axis_x = 0
  c102: - 1 x00025_right_decorations_area_canvas_y + 1 x00067_axis_y = 0
  c103: - 1 x00026_right_decorations_area_canvas_height + 1 x00063_axis_size + 1 x00064_axis_margin_start + 1 x00065_axis_margin_end = 0
  c104: - 1 x00024_right_decorations_area_canvas_x - 1 x00027_right_decorations_area_canvas_width + 1 x00088_right_axis_canvas_canvas_x + 1 x00091_right_axis_canvas_canvas_width <= 0
  c105: - 1 x00024_right_decorations_area_canvas_x + 1 x00088_right_axis_canvas_canvas_x >= 0
  c106: - 1 x00032_bottom_decorations_area_canvas_x + 1 x00092_bottom_axis_canvas_canvas_x = 0
  c107: - 1 x00033_bottom_decorations_area_canvas_y + 1 x00093_bottom_axis_canvas_canvas_y = 0
  c108: - 1 x00035_bottom_decorations_area_canvas_width + 1 x00095_bottom_axis_canvas_canvas_width = 0
  c109: - 1 x00032_bottom_decorations_area_canvas_x + 1 x00051_axis_x = 0
  c11: 1 x00013_data_area_canvas_y + 1 x00014_data_area_canvas_height - 1 x00025_right_decorations_area_canvas_y - 1 x00026_right_decorations_area_canvas_height = 0
  c110: - 1 x00033_bottom_decorations_area_canvas_y + 1 x00052_axis_y = 0
  c111: - 1 x00035_bottom_decorations_area_canvas_width + 1 x00048_axis_size + 1 x00049_axis_margin_start + 1 x00050_axis_margin_end = 0
  c112: 1.0 x00076_text_x + 0.5 x00079_text_width - 1.0 x00092_bottom_axis_canvas_canvas_x - 0.5 x00095_bottom_axis_canvas_canvas_width = 0
  c113: 1 x00077_text_y - 1 x00093_bottom_axis_canvas_canvas_y = 15
  c114: 1 x00077_text_y - 1 x00093_bottom_axis_canvas_canvas_y >= 0
  c115: 1 x00077_text_y + 1 x00078_text_height - 1 x00093_bottom_axis_canvas_canvas_y - 1 x00094_bottom_axis_canvas_canvas_height <= 0
  c116: - 1 x00033_bottom_decorations_area_canvas_y + 1 x00093_bottom_axis_canvas_canvas_y >= 0
  c117: - 1 x00033_bottom_decorations_area_canvas_y - 1 x00034_bottom_decorations_area_canvas_height + 1 x00093_bottom_axis_canvas_canvas_y + 1 x00094_bottom_axis_canvas_canvas_height <= 0
  c12: - 1 x00033_bottom_decorations_area_canvas_y + 1 x00037_bottom_left_decorations_area_canvas_y = 0
  c13: - 1 x00029_bottom_right_decorations_area_canvas_y + 1 x00033_bottom_decorations_area_canvas_y = 0
  c14: - 1 x00033_bottom_decorations_area_canvas_y - 1 x00034_bottom_decorations_area_canvas_height + 1 x00037_bottom_left_decorations_area_canvas_y + 1 x00038_bottom_left_decorations_area_canvas_height = 0
  c15: - 1 x00029_bottom_right_decorations_area_canvas_y - 1 x00030_bottom_right_decorations_area_canvas_height + 1 x00033_bottom_decorations_area_canvas_y + 1 x00034_bottom_decorations_area_canvas_height = 0
  c16: 1 x00008_title_area_canvas_x - 1 x00044_top_left_decorations_area_canvas_x = 0
  c17: - 1 x00040_left_decorations_area_canvas_x + 1 x00044_top_left_decorations_area_canvas_x = 0
  c18: - 1 x00036_bottom_left_decorations_area_canvas_x + 1 x00040_left_decorations_area_canvas_x = 0
  c19: - 1 x00040_left_decorations_area_canvas_x - 1 x00043_left_decorations_area_canvas_width + 1 x00044_top_left_decorations_area_canvas_x + 1 x00047_top_left_decorations_area_canvas_width = 0
  c2: - 1 x00003_plot_bounds_right + 1 x00004_plot_area_canvas_x + 1 x00007_plot_area_canvas_width = 0
  c20: - 1 x00036_bottom_left_decorations_area_canvas_x - 1 x00039_bottom_left_decorations_area_canvas_width + 1 x00040_left_decorations_area_canvas_x + 1 x00043_left_decorations_area_canvas_width = 0
  c21: - 1 x00012_data_area_canvas_x + 1 x00016_top_decorations_area_canvas_x = 0
  c22: 1 x00012_data_area_canvas_x - 1 x00032_bottom_decorations_area_canvas_x = 0
  c23: - 1 x00012_data_area_canvas_x - 1 x00015_data_area_canvas_width + 1 x00016_top_decorations_area_canvas_x + 1 x00019_top_decorations_area_canvas_width = 0
  c24: 1 x00012_data_area_canvas_x + 1 x00015_data_area_canvas_width - 1 x00032_bottom_decorations_area_canvas_x - 1 x00035_bottom_decorations_area_canvas_width = 0
  c25: 1 x00020_top_right_decorations_area_canvas_x - 1 x00024_right_decorations_area_canvas_x = 0
  c26: 1 x00024_right_decorations_area_canvas_x - 1 x00028_bottom_right_decorations_area_canvas_x = 0
  c27: 1 x00020_top_right_decorations_area_canvas_x + 1 x00023_top_right_decorations_area_canvas_width - 1 x00024_right_decorations_area_canvas_x - 1 x00027_right_decorations_area_canvas_width = 0
  c28: 1 x00024_right_decorations_area_canvas_x + 1 x00027_right_decorations_area_canvas_width - 1 x00028_bottom_right_decorations_area_canvas_x - 1 x00031_bottom_right_decorations_area_canvas_width = 0
  c29: - 1 x00016_top_decorations_area_canvas_x + 1 x00044_top_left_decorations_area_canvas_x + 1 x00047_top_left_decorations_area_canvas_width = 0
  c3: - 1 x00001_plot_bounds_bottom + 1 x00005_plot_area_canvas_y + 1 x00006_plot_area_canvas_height = 0
  c30: 1 x00016_top_decorations_area_canvas_x + 1 x00019_top_decorations_area_canvas_width - 1 x00020_top_right_decorations_area_canvas_x = 0
  c31: - 1 x00004_plot_area_canvas_x + 1 x00044_top_left_decorations_area_canvas_x >= 0
  c32: - 1 x00004_plot_area_canvas_x - 1 x00007_plot_area_canvas_width + 1 x00020_top_right_decorations_area_canvas_x + 1 x00023_top_right_decorations_area_canvas_width <= 0
  c33: - 1 x00012_data_area_canvas_x + 1 x00040_left_decorations_area_canvas_x + 1 x00043_left_decorations_area_canvas_width = 0
  c34: 1 x00012_data_area_canvas_x + 1 x00015_data_area_canvas_width - 1 x00024_right_decorations_area_canvas_x = 0
  c35: - 1 x00004_plot_area_canvas_x + 1 x00040_left_decorations_area_canvas_x >= 0
  c36: - 1 x00004_plot_area_canvas_x - 1 x00007_plot_area_canvas_width + 1 x00024_right_decorations_area_canvas_x + 1 x00027_right_decorations_area_canvas_width <= 0
  c37: - 1 x00032_bottom_decorations_area_canvas_x + 1 x00036_bottom_left_decorations_area_canvas_x + 1 x00039_bottom_left_decorations_area_canvas_width = 0
  c38: - 1 x00028_bottom_right_decorations_area_canvas_x + 1 x00032_bottom_decorations_area_canvas_x + 1 x00035_bottom_decorations_area_canvas_width = 0
  c39: - 1 x00004_plot_area_canvas_x + 1 x00036_bottom_left_decorations_area_canvas_x >= 0
  c4: - 1 x00017_top_decorations_area_canvas_y + 1 x00045_top_left_decorations_area_canvas_y = 0
  c40: - 1 x00004_plot_area_canvas_x - 1 x00007_plot_area_canvas_width + 1 x00028_bottom_right_decorations_area_canvas_x + 1 x00031_bottom_right_decorations_area_canvas_width <= 0
  c41: 1 x00009_title_area_canvas_y + 1 x00010_title_area_canvas_height - 1 x00045_top_left_decorations_area_canvas_y = 0
  c42: - 1 x00041_left_decorations_area_canvas_y + 1 x00045_top_left_decorations_area_canvas_y + 1 x00046_top_left_decorations_area_canvas_height = 0
  c43: - 1 x00037_bottom_left_decorations_area_canvas_y + 1 x00041_left_decorations_area_canvas_y + 1 x00042_left_decorations_area_canvas_height = 0
  c44: - 1 x00005_plot_area_canvas_y + 1 x00009_title_area_canvas_y >= 0
  c45: - 1 x00005_plot_area_canvas_y - 1 x00006_plot_area_canvas_height + 1 x00037_bottom_left_decorations_area_canvas_y + 1 x00038_bottom_left_decorations_area_canvas_height <= 0
  c46: 1 x00009_title_area_canvas_y + 1 x00010_title_area_canvas_height - 1 x00017_top_decorations_area_canvas_y = 0
  c47: - 1 x00013_data_area_canvas_y + 1 x00017_top_decorations_area_canvas_y + 1 x00018_top_decorations_area_canvas_height = 0
  c48: 1 x00013_data_area_canvas_y + 1 x00014_data_area_canvas_height - 1 x00033_bottom_decorations_area_canvas_y = 0
  c49: - 1 x00005_plot_area_canvas_y + 1 x00009_title_area_canvas_y >= 0
  c5: 1 x00017_top_decorations_area_canvas_y - 1 x00021_top_right_decorations_area_canvas_y = 0
  c50: - 1 x00005_plot_area_canvas_y - 1 x00006_plot_area_canvas_height + 1 x00033_bottom_decorations_area_canvas_y + 1 x00034_bottom_decorations_area_canvas_height <= 0
  c51: 1 x00009_title_area_canvas_y + 1 x00010_title_area_canvas_height - 1 x00021_top_right_decorations_area_canvas_y = 0
  c52: 1 x00021_top_right_decorations_area_canvas_y + 1 x00022_top_right_decorations_area_canvas_height - 1 x00025_right_decorations_area_canvas_y = 0
  c53: 1 x00025_right_decorations_area_canvas_y + 1 x00026_right_decorations_area_canvas_height - 1 x00029_bottom_right_decorations_area_canvas_y = 0
  c54: - 1 x00005_plot_area_canvas_y + 1 x00009_title_area_canvas_y >= 0
  c55: - 1 x00005_plot_area_canvas_y - 1 x00006_plot_area_canvas_height + 1 x00029_bottom_right_decorations_area_canvas_y + 1 x00030_bottom_right_decorations_area_canvas_height <= 0
  c56: 1 x00050_axis_margin_end >= 7.086614173228346
  c57: 1 x00049_axis_margin_start >= 7.086614173228346
  c58: 1 x00060_axis_margin_end >= 7.086614173228346
  c59: 1 x00059_axis_margin_start >= 7.086614173228346
  c6: - 1 x00017_top_decorations_area_canvas_y - 1 x00018_top_decorations_area_canvas_height + 1 x00045_top_left_decorations_area_canvas_y + 1 x00046_top_left_decorations_area_canvas_height = 0
  c60: 1 x00055_axis_margin_end >= 7.086614173228346
  c61: 1 x00054_axis_margin_start >= 7.086614173228346
  c62: 1 x00065_axis_margin_end >= 7.086614173228346
  c63: 1 x00064_axis_margin_start >= 7.086614173228346
  c64: 1 x00000_plot_bounds_top = 0
  c65: 1 x00001_plot_bounds_bottom = 170.0787401574803
  c66: 1 x00002_plot_bounds_left = 0
  c67: 1 x00003_plot_bounds_right = 226.77165354330708
  c68: 1 x00071_text_width = 46.16999816894531
  c69: 1 x00070_text_height = 8.64900016784668
  c7: 1 x00017_top_decorations_area_canvas_y + 1 x00018_top_decorations_area_canvas_height - 1 x00021_top_right_decorations_area_canvas_y - 1 x00022_top_right_decorations_area_canvas_height = 0
  c70: 1 x00075_text_width = 58.83300018310547
  c71: 1 x00074_text_height = 8.711999893188477
  c72: 1 x00079_text_width = 45.97200012207031
  c73: 1 x00078_text_height = 7.10099983215332
  c74: - 1 x00008_title_area_canvas_x + 1 x00068_text_x = 0
  c75: - 1 x00009_title_area_canvas_y - 1 x00010_title_area_canvas_height + 1 x00069_text_y + 1 x00070_text_height = -12
  c76: - 1 x00009_title_area_canvas_y + 1 x00069_text_y >= 0
  c77: - 1 x00009_title_area_canvas_y - 1 x00010_title_area_canvas_height + 1 x00069_text_y + 1 x00070_text_height <= 0
  c78: - 1 x00042_left_decorations_area_canvas_height + 1 x00082_left_axis_canvas_canvas_height = 0
  c79: - 1 x00041_left_decorations_area_canvas_y + 1 x00081_left_axis_canvas_canvas_y = 0
  c8: - 1 x00013_data_area_canvas_y + 1 x00041_left_decorations_area_canvas_y = 0
  c80: - 1 x00040_left_decorations_area_canvas_x - 1 x00043_left_decorations_area_canvas_width + 1 x00080_left_axis_canvas_canvas_x + 1 x00083_left_axis_canvas_canvas_width = 0
  c81: - 1 x00040_left_decorations_area_canvas_x - 1 x00043_left_decorations_area_canvas_width + 1 x00056_axis_x = 0
  c82: - 1 x00041_left_decorations_area_canvas_y + 1 x00057_axis_y = 0
  c83: - 1 x00042_left_decorations_area_canvas_height + 1 x00053_axis_size + 1 x00054_axis_margin_start + 1 x00055_axis_margin_end = 0
  c84: - 1 x00080_left_axis_canvas_canvas_x - 1 x00083_left_axis_canvas_canvas_width = -15
  c85: - 0.5 x00075_text_width - 1.0 x00081_left_axis_canvas_canvas_y - 0.5 x00082_left_axis_canvas_canvas_height = 0
  c86: - 1 x00080_left_axis_canvas_canvas_x - 1 x00083_left_axis_canvas_canvas_width <= 0
  c87: - 1 x00074_text_height - 1 x00080_left_axis_canvas_canvas_x >= 0
  c88: - 1 x00040_left_decorations_area_canvas_x - 1 x00043_left_decorations_area_canvas_width + 1 x00080_left_axis_canvas_canvas_x + 1 x00083_left_axis_canvas_canvas_width <= 0
  c89: - 1 x00040_left_decorations_area_canvas_x + 1 x00080_left_axis_canvas_canvas_x >= 0
  c9: 1 x00013_data_area_canvas_y - 1 x00025_right_decorations_area_canvas_y = 0
  c90: - 1 x00019_top_decorations_area_canvas_width + 1 x00087_top_axis_canvas_canvas_width = 0
  c91: - 1 x00016_top_decorations_area_canvas_x + 1 x00084_top_axis_canvas_canvas_x = 0
  c92: - 1 x00017_top_decorations_area_canvas_y - 1 x00018_top_decorations_area_canvas_height + 1 x00085_top_axis_canvas_canvas_y + 1 x00086_top_axis_canvas_canvas_height = 0
  c93: - 1 x00016_top_decorations_area_canvas_x + 1 x00061_axis_x = 0
  c94: - 1 x00017_top_decorations_area_canvas_y - 1 x00018_top_decorations_area_canvas_height + 1 x00062_axis_y = 0
  c95: - 1 x00019_top_decorations_area_canvas_width + 1 x00058_axis_size + 1 x00059_axis_margin_start + 1 x00060_axis_margin_end = 0
  c96: - 1 x00017_top_decorations_area_canvas_y + 1 x00085_top_axis_canvas_canvas_y >= 0
  c97: - 1 x00017_top_decorations_area_canvas_y - 1 x00018_top_decorations_area_canvas_height + 1 x00085_top_axis_canvas_canvas_y + 1 x00086_top_axis_canvas_canvas_height <= 0
  c98: - 1 x00026_right_decorations_area_canvas_height + 1 x00090_right_axis_canvas_canvas_height = 0
  c99: - 1 x00024_right_decorations_area_canvas_x + 1 x00088_right_axis_canvas_canvas_x = 0
Bounds
  x00025_right_decorations_area_canvas_y free
  0 <= x00006_plot_area_canvas_height
  x00073_text_y free
  0.0 <= x00053_axis_size
  0 <= x00030_bottom_right_decorations_area_canvas_height
  0 <= x00086_top_axis_canvas_canvas_height
  0 <= x00018_top_decorations_area_canvas_height
  x00052_axis_y free
  0.0 <= x00050_axis_margin_end
  x00003_plot_bounds_right free
  x00088_right_axis_canvas_canvas_x free
  0 <= x00083_left_axis_canvas_canvas_width
  0 <= x00075_text_width
  x00093_bottom_axis_canvas_canvas_y free
  0 <= x00039_bottom_left_decorations_area_canvas_width
  0.0 <= x00055_axis_margin_end
  x00032_bottom_decorations_area_canvas_x free
  0 <= x00043_left_decorations_area_canvas_width
  x00033_bottom_decorations_area_canvas_y free
  x00017_top_decorations_area_canvas_y free
  x00092_bottom_axis_canvas_canvas_x free
  0 <= x00078_text_height
  0 <= x00074_text_height
  0.0 <= x00049_axis_margin_start
  0 <= x00046_top_left_decorations_area_canvas_height
  0.0 <= x00063_axis_size
  0 <= x00031_bottom_right_decorations_area_canvas_width
  0.0 <= x00058_axis_size
  x00057_axis_y free
  x00069_text_y free
  0 <= x00047_top_left_decorations_area_canvas_width
  0 <= x00014_data_area_canvas_height
  0 <= x00095_bottom_axis_canvas_canvas_width
  x00024_right_decorations_area_canvas_x free
  x00036_bottom_left_decorations_area_canvas_x free
  x00041_left_decorations_area_canvas_y free
  x00045_top_left_decorations_area_canvas_y free
  x00067_axis_y free
  x00085_top_axis_canvas_canvas_y free
  0 <= x00011_title_area_canvas_width
  x00021_top_right_decorations_area_canvas_y free
  x00012_data_area_canvas_x free
  x00062_axis_y free
  0 <= x00087_top_axis_canvas_canvas_width
  0 <= x00023_top_right_decorations_area_canvas_width
  0 <= x00019_top_decorations_area_canvas_width
  0 <= x00082_left_axis_canvas_canvas_height
  0 <= x00026_right_decorations_area_canvas_height
  x00084_top_axis_canvas_canvas_x free
  0.0 <= x00064_axis_margin_start
  x00028_bottom_right_decorations_area_canvas_x free
  x00076_text_x free
  x00016_top_decorations_area_canvas_x free
  x00081_left_axis_canvas_canvas_y free
  0.0 <= x00048_axis_size
  0 <= x00038_bottom_left_decorations_area_canvas_height
  x00029_bottom_right_decorations_area_canvas_y free
  x00051_axis_x free
  x00009_title_area_canvas_y free
  0 <= x00022_top_right_decorations_area_canvas_height
  x00001_plot_bounds_bottom free
  x00000_plot_bounds_top free
  x00037_bottom_left_decorations_area_canvas_y free
  x00077_text_y free
  0 <= x00091_right_axis_canvas_canvas_width
  0.0 <= x00065_axis_margin_end
  x00004_plot_area_canvas_x free
  x00056_axis_x free
  0 <= x00094_bottom_axis_canvas_canvas_height
  0.0 <= x00054_axis_margin_start
  x00080_left_axis_canvas_canvas_x free
  x00061_axis_x free
  x00072_text_x free
  0.0 <= x00059_axis_margin_start
  0 <= x00035_bottom_decorations_area_canvas_width
  0 <= x00027_right_decorations_area_canvas_width
  0 <= x00071_text_width
  0 <= x00079_text_width
  x00044_top_left_decorations_area_canvas_x free
  0.0 <= x00060_axis_margin_end
  x00089_right_axis_canvas_canvas_y free
  x00020_top_right_decorations_area_canvas_x free
  0 <= x00034_bottom_decorations_area_canvas_height
  0 <= x00042_left_decorations_area_canvas_height
  x00068_text_x free
  0 <= x00070_text_height
  0 <= x00010_title_area_canvas_height
  x00040_left_decorations_area_canvas_x free
  x00002_plot_bounds_left free
  x00005_plot_area_canvas_y free
  x00013_data_area_canvas_y free
  0 <= x00090_right_axis_canvas_canvas_height
  0 <= x00007_plot_area_canvas_width
  x00008_title_area_canvas_x free
  x00066_axis_x free
  0 <= x00015_data_area_canvas_width
General
End
