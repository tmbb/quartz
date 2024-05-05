Maximize
  - 10 x00000000_figure_width - 10 x00000001_figure_height - 10 x00000012_title_area_canvas_height - 10 x00000020_top_decorations_area_canvas_height - 10 x00000029_right_decorations_area_canvas_width - 10 x00000036_bottom_decorations_area_canvas_height - 10 x00000045_left_decorations_area_canvas_width + 10 x00000050_x_axis_size - 20 x00000051_x_axis_margin_start - 20 x00000052_x_axis_margin_end + 10 x00000055_y_axis_size - 20 x00000056_y_axis_margin_start - 20 x00000057_y_axis_margin_end + 10 x00000060_x2_axis_size - 20 x00000061_x2_axis_margin_start - 20 x00000062_x2_axis_margin_end + 10 x00000065_y2_axis_size - 20 x00000066_y2_axis_margin_start - 20 x00000067_y2_axis_margin_end - 10 x00000088_left_axis_canvas_canvas_width + 10 x00000089_labels_left_bound - 10 x00000092_top_axis_canvas_canvas_height - 10 x00000094_tick_label_baseline + 10 x00000095_tick_label_bottom - 10 x00000099_right_axis_canvas_canvas_width - 10 x00000100_labels_right_bound - 10 x00000103_bottom_axis_canvas_canvas_height - 10 x00000105_tick_label_baseline - 10 x00000106_tick_label_bottom
Subject To
  c0: - 1 x00000002_plot_bounds_top + 1 x00000007_plot_area_canvas_y = 0
  c1: - 1 x00000004_plot_bounds_left + 1 x00000006_plot_area_canvas_x = 0
  c10: - 1 x00000015_data_area_canvas_y - 1 x00000016_data_area_canvas_height + 1 x00000043_left_decorations_area_canvas_y + 1 x00000044_left_decorations_area_canvas_height = 0
  c100: - 1 x00000027_right_decorations_area_canvas_y + 1 x00000097_right_axis_canvas_canvas_y = 0
  c101: - 1 x00000026_right_decorations_area_canvas_x + 1 x00000068_y2_axis_x = 0
  c102: - 1 x00000027_right_decorations_area_canvas_y + 1 x00000069_y2_axis_y = 0
  c103: - 1 x00000028_right_decorations_area_canvas_height + 1 x00000065_y2_axis_size + 1 x00000066_y2_axis_margin_start + 1 x00000067_y2_axis_margin_end = 0
  c104: - 1 x00000026_right_decorations_area_canvas_x + 1 x00000100_labels_right_bound >= 4
  c105: - 1 x00000026_right_decorations_area_canvas_x - 1 x00000029_right_decorations_area_canvas_width + 1 x00000096_right_axis_canvas_canvas_x + 1 x00000099_right_axis_canvas_canvas_width <= 0
  c106: - 1 x00000026_right_decorations_area_canvas_x + 1 x00000096_right_axis_canvas_canvas_x >= 0
  c107: - 1 x00000034_bottom_decorations_area_canvas_x + 1 x00000101_bottom_axis_canvas_canvas_x = 0
  c108: - 1 x00000035_bottom_decorations_area_canvas_y + 1 x00000102_bottom_axis_canvas_canvas_y = 0
  c109: - 1 x00000037_bottom_decorations_area_canvas_width + 1 x00000104_bottom_axis_canvas_canvas_width = 0
  c11: 1 x00000015_data_area_canvas_y + 1 x00000016_data_area_canvas_height - 1 x00000027_right_decorations_area_canvas_y - 1 x00000028_right_decorations_area_canvas_height = 0
  c110: - 1 x00000034_bottom_decorations_area_canvas_x + 1 x00000053_x_axis_x = 0
  c111: - 1 x00000035_bottom_decorations_area_canvas_y + 1 x00000054_x_axis_y = 0
  c112: - 1 x00000037_bottom_decorations_area_canvas_width + 1 x00000050_x_axis_size + 1 x00000051_x_axis_margin_start + 1 x00000052_x_axis_margin_end = 0
  c113: - 1 x00000035_bottom_decorations_area_canvas_y + 1 x00000105_tick_label_baseline >= 7
  c114: - 1 x00000035_bottom_decorations_area_canvas_y + 1 x00000106_tick_label_bottom >= 7
  c115: - 0.125655787525916 x00000050_x_axis_size - 1 x00000051_x_axis_margin_start - 1 x00000053_x_axis_x + 1.0 x00000107_text_x + 0.5 x00000110_text_width = 0
  c116: - 1 x00000026_right_decorations_area_canvas_x - 1 x00000029_right_decorations_area_canvas_width + 1 x00000107_text_x + 1 x00000110_text_width <= 0
  c117: - 1 x00000042_left_decorations_area_canvas_x + 1 x00000107_text_x >= 0
  c118: - 1 x00000105_tick_label_baseline + 1 x00000108_text_y = 0
  c119: - 1 x00000035_bottom_decorations_area_canvas_y + 1 x00000108_text_y - 1 x00000109_text_height >= 7
  c12: - 1 x00000035_bottom_decorations_area_canvas_y + 1 x00000039_bottom_left_decorations_area_canvas_y = 0
  c120: 1 x00000106_tick_label_bottom - 1 x00000108_text_y - 1 x00000111_text_depth >= 0
  c121: - 0.26890730180186057 x00000050_x_axis_size - 1 x00000051_x_axis_margin_start - 1 x00000053_x_axis_x + 1.0 x00000112_text_x + 0.5 x00000115_text_width = 0
  c122: - 1 x00000026_right_decorations_area_canvas_x - 1 x00000029_right_decorations_area_canvas_width + 1 x00000112_text_x + 1 x00000115_text_width <= 0
  c123: - 1 x00000042_left_decorations_area_canvas_x + 1 x00000112_text_x >= 0
  c124: - 1 x00000105_tick_label_baseline + 1 x00000113_text_y = 0
  c125: - 1 x00000035_bottom_decorations_area_canvas_y + 1 x00000113_text_y - 1 x00000114_text_height >= 7
  c126: 1 x00000106_tick_label_bottom - 1 x00000113_text_y - 1 x00000116_text_depth >= 0
  c127: - 0.41215881607780513 x00000050_x_axis_size - 1 x00000051_x_axis_margin_start - 1 x00000053_x_axis_x + 1.0 x00000117_text_x + 0.5 x00000120_text_width = 0
  c128: - 1 x00000026_right_decorations_area_canvas_x - 1 x00000029_right_decorations_area_canvas_width + 1 x00000117_text_x + 1 x00000120_text_width <= 0
  c129: - 1 x00000042_left_decorations_area_canvas_x + 1 x00000117_text_x >= 0
  c13: - 1 x00000031_bottom_right_decorations_area_canvas_y + 1 x00000035_bottom_decorations_area_canvas_y = 0
  c130: - 1 x00000105_tick_label_baseline + 1 x00000118_text_y = 0
  c131: - 1 x00000035_bottom_decorations_area_canvas_y + 1 x00000118_text_y - 1 x00000119_text_height >= 7
  c132: 1 x00000106_tick_label_bottom - 1 x00000118_text_y - 1 x00000121_text_depth >= 0
  c133: - 0.5554103303537496 x00000050_x_axis_size - 1 x00000051_x_axis_margin_start - 1 x00000053_x_axis_x + 1.0 x00000122_text_x + 0.5 x00000125_text_width = 0
  c134: - 1 x00000026_right_decorations_area_canvas_x - 1 x00000029_right_decorations_area_canvas_width + 1 x00000122_text_x + 1 x00000125_text_width <= 0
  c135: - 1 x00000042_left_decorations_area_canvas_x + 1 x00000122_text_x >= 0
  c136: - 1 x00000105_tick_label_baseline + 1 x00000123_text_y = 0
  c137: - 1 x00000035_bottom_decorations_area_canvas_y + 1 x00000123_text_y - 1 x00000124_text_height >= 7
  c138: 1 x00000106_tick_label_bottom - 1 x00000123_text_y - 1 x00000126_text_depth >= 0
  c139: - 0.6986618446296942 x00000050_x_axis_size - 1 x00000051_x_axis_margin_start - 1 x00000053_x_axis_x + 1.0 x00000127_text_x + 0.5 x00000130_text_width = 0
  c14: - 1 x00000035_bottom_decorations_area_canvas_y - 1 x00000036_bottom_decorations_area_canvas_height + 1 x00000039_bottom_left_decorations_area_canvas_y + 1 x00000040_bottom_left_decorations_area_canvas_height = 0
  c140: - 1 x00000026_right_decorations_area_canvas_x - 1 x00000029_right_decorations_area_canvas_width + 1 x00000127_text_x + 1 x00000130_text_width <= 0
  c141: - 1 x00000042_left_decorations_area_canvas_x + 1 x00000127_text_x >= 0
  c142: - 1 x00000105_tick_label_baseline + 1 x00000128_text_y = 0
  c143: - 1 x00000035_bottom_decorations_area_canvas_y + 1 x00000128_text_y - 1 x00000129_text_height >= 7
  c144: 1 x00000106_tick_label_bottom - 1 x00000128_text_y - 1 x00000131_text_depth >= 0
  c145: - 0.8419133589056387 x00000050_x_axis_size - 1 x00000051_x_axis_margin_start - 1 x00000053_x_axis_x + 1.0 x00000132_text_x + 0.5 x00000135_text_width = 0
  c146: - 1 x00000026_right_decorations_area_canvas_x - 1 x00000029_right_decorations_area_canvas_width + 1 x00000132_text_x + 1 x00000135_text_width <= 0
  c147: - 1 x00000042_left_decorations_area_canvas_x + 1 x00000132_text_x >= 0
  c148: - 1 x00000105_tick_label_baseline + 1 x00000133_text_y = 0
  c149: - 1 x00000035_bottom_decorations_area_canvas_y + 1 x00000133_text_y - 1 x00000134_text_height >= 7
  c15: - 1 x00000031_bottom_right_decorations_area_canvas_y - 1 x00000032_bottom_right_decorations_area_canvas_height + 1 x00000035_bottom_decorations_area_canvas_y + 1 x00000036_bottom_decorations_area_canvas_height = 0
  c150: 1 x00000106_tick_label_bottom - 1 x00000133_text_y - 1 x00000136_text_depth >= 0
  c151: - 0.9851648731815833 x00000050_x_axis_size - 1 x00000051_x_axis_margin_start - 1 x00000053_x_axis_x + 1.0 x00000137_text_x + 0.5 x00000140_text_width = 0
  c152: - 1 x00000026_right_decorations_area_canvas_x - 1 x00000029_right_decorations_area_canvas_width + 1 x00000137_text_x + 1 x00000140_text_width <= 0
  c153: - 1 x00000042_left_decorations_area_canvas_x + 1 x00000137_text_x >= 0
  c154: - 1 x00000105_tick_label_baseline + 1 x00000138_text_y = 0
  c155: - 1 x00000035_bottom_decorations_area_canvas_y + 1 x00000138_text_y - 1 x00000139_text_height >= 7
  c156: 1 x00000106_tick_label_bottom - 1 x00000138_text_y - 1 x00000141_text_depth >= 0
  c157: - 1 x00000102_bottom_axis_canvas_canvas_y - 1 x00000103_bottom_axis_canvas_canvas_height + 1 x00000106_tick_label_bottom <= 0
  c158: 1.0 x00000075_text_x + 0.5 x00000078_text_width - 1.0 x00000101_bottom_axis_canvas_canvas_x - 0.5 x00000104_bottom_axis_canvas_canvas_width = 0
  c159: 1 x00000035_bottom_decorations_area_canvas_y + 1 x00000076_text_y - 1 x00000077_text_height - 1 x00000102_bottom_axis_canvas_canvas_y - 1 x00000106_tick_label_bottom = 8
  c16: 1 x00000010_title_area_canvas_x - 1 x00000046_top_left_decorations_area_canvas_x = 0
  c160: 1 x00000076_text_y - 1 x00000077_text_height - 1 x00000102_bottom_axis_canvas_canvas_y >= 0
  c161: 1 x00000076_text_y + 1 x00000079_text_depth - 1 x00000102_bottom_axis_canvas_canvas_y - 1 x00000103_bottom_axis_canvas_canvas_height <= 0
  c162: - 1 x00000035_bottom_decorations_area_canvas_y + 1 x00000102_bottom_axis_canvas_canvas_y >= 0
  c163: - 1 x00000035_bottom_decorations_area_canvas_y - 1 x00000036_bottom_decorations_area_canvas_height + 1 x00000102_bottom_axis_canvas_canvas_y + 1 x00000103_bottom_axis_canvas_canvas_height <= 0
  c164: 1 x00000073_plot_title_text_width = 111.38400268554688
  c165: 1 x00000072_plot_title_text_height = 6.984000205993652
  c166: 1 x00000078_text_width = 4.256999969482422
  c167: 1 x00000077_text_height = 6.75
  c168: 1 x00000083_text_width = 14.958000183105469
  c169: 1 x00000082_text_height = 6.974999904632568
  c17: - 1 x00000042_left_decorations_area_canvas_x + 1 x00000046_top_left_decorations_area_canvas_x = 0
  c170: 1 x00000110_text_width = 10.16100025177002
  c171: 1 x00000109_text_height = 6.38100004196167
  c172: 1 x00000115_text_width = 11.25
  c173: 1 x00000114_text_height = 6.38100004196167
  c174: 1 x00000120_text_width = 11.241000175476074
  c175: 1 x00000119_text_height = 6.38100004196167
  c176: 1 x00000125_text_width = 11.538000106811523
  c177: 1 x00000124_text_height = 6.38100004196167
  c178: 1 x00000130_text_width = 11.258999824523926
  c179: 1 x00000129_text_height = 6.38100004196167
  c18: - 1 x00000038_bottom_left_decorations_area_canvas_x + 1 x00000042_left_decorations_area_canvas_x = 0
  c180: 1 x00000135_text_width = 11.456999778747559
  c181: 1 x00000134_text_height = 6.38100004196167
  c182: 1 x00000140_text_width = 11.348999977111816
  c183: 1 x00000139_text_height = 6.38100004196167
  c19: - 1 x00000042_left_decorations_area_canvas_x - 1 x00000045_left_decorations_area_canvas_width + 1 x00000046_top_left_decorations_area_canvas_x + 1 x00000049_top_left_decorations_area_canvas_width = 0
  c2: - 1 x00000005_plot_bounds_right + 1 x00000006_plot_area_canvas_x + 1 x00000009_plot_area_canvas_width = 0
  c20: - 1 x00000038_bottom_left_decorations_area_canvas_x - 1 x00000041_bottom_left_decorations_area_canvas_width + 1 x00000042_left_decorations_area_canvas_x + 1 x00000045_left_decorations_area_canvas_width = 0
  c21: - 1 x00000014_data_area_canvas_x + 1 x00000018_top_decorations_area_canvas_x = 0
  c22: 1 x00000014_data_area_canvas_x - 1 x00000034_bottom_decorations_area_canvas_x = 0
  c23: - 1 x00000014_data_area_canvas_x - 1 x00000017_data_area_canvas_width + 1 x00000018_top_decorations_area_canvas_x + 1 x00000021_top_decorations_area_canvas_width = 0
  c24: 1 x00000014_data_area_canvas_x + 1 x00000017_data_area_canvas_width - 1 x00000034_bottom_decorations_area_canvas_x - 1 x00000037_bottom_decorations_area_canvas_width = 0
  c25: 1 x00000022_top_right_decorations_area_canvas_x - 1 x00000026_right_decorations_area_canvas_x = 0
  c26: 1 x00000026_right_decorations_area_canvas_x - 1 x00000030_bottom_right_decorations_area_canvas_x = 0
  c27: 1 x00000022_top_right_decorations_area_canvas_x + 1 x00000025_top_right_decorations_area_canvas_width - 1 x00000026_right_decorations_area_canvas_x - 1 x00000029_right_decorations_area_canvas_width = 0
  c28: 1 x00000026_right_decorations_area_canvas_x + 1 x00000029_right_decorations_area_canvas_width - 1 x00000030_bottom_right_decorations_area_canvas_x - 1 x00000033_bottom_right_decorations_area_canvas_width = 0
  c29: - 1 x00000018_top_decorations_area_canvas_x + 1 x00000046_top_left_decorations_area_canvas_x + 1 x00000049_top_left_decorations_area_canvas_width = 0
  c3: - 1 x00000003_plot_bounds_bottom + 1 x00000007_plot_area_canvas_y + 1 x00000008_plot_area_canvas_height = 0
  c30: 1 x00000018_top_decorations_area_canvas_x + 1 x00000021_top_decorations_area_canvas_width - 1 x00000022_top_right_decorations_area_canvas_x = 0
  c31: - 1 x00000006_plot_area_canvas_x + 1 x00000046_top_left_decorations_area_canvas_x >= 0
  c32: - 1 x00000006_plot_area_canvas_x - 1 x00000009_plot_area_canvas_width + 1 x00000022_top_right_decorations_area_canvas_x + 1 x00000025_top_right_decorations_area_canvas_width <= 0
  c33: - 1 x00000014_data_area_canvas_x + 1 x00000042_left_decorations_area_canvas_x + 1 x00000045_left_decorations_area_canvas_width = 0
  c34: 1 x00000014_data_area_canvas_x + 1 x00000017_data_area_canvas_width - 1 x00000026_right_decorations_area_canvas_x = 0
  c35: - 1 x00000006_plot_area_canvas_x + 1 x00000042_left_decorations_area_canvas_x >= 0
  c36: - 1 x00000006_plot_area_canvas_x - 1 x00000009_plot_area_canvas_width + 1 x00000026_right_decorations_area_canvas_x + 1 x00000029_right_decorations_area_canvas_width <= 0
  c37: - 1 x00000034_bottom_decorations_area_canvas_x + 1 x00000038_bottom_left_decorations_area_canvas_x + 1 x00000041_bottom_left_decorations_area_canvas_width = 0
  c38: - 1 x00000030_bottom_right_decorations_area_canvas_x + 1 x00000034_bottom_decorations_area_canvas_x + 1 x00000037_bottom_decorations_area_canvas_width = 0
  c39: - 1 x00000006_plot_area_canvas_x + 1 x00000038_bottom_left_decorations_area_canvas_x >= 0
  c4: - 1 x00000019_top_decorations_area_canvas_y + 1 x00000047_top_left_decorations_area_canvas_y = 0
  c40: - 1 x00000006_plot_area_canvas_x - 1 x00000009_plot_area_canvas_width + 1 x00000030_bottom_right_decorations_area_canvas_x + 1 x00000033_bottom_right_decorations_area_canvas_width <= 0
  c41: 1 x00000011_title_area_canvas_y + 1 x00000012_title_area_canvas_height - 1 x00000047_top_left_decorations_area_canvas_y = 0
  c42: - 1 x00000043_left_decorations_area_canvas_y + 1 x00000047_top_left_decorations_area_canvas_y + 1 x00000048_top_left_decorations_area_canvas_height = 0
  c43: - 1 x00000039_bottom_left_decorations_area_canvas_y + 1 x00000043_left_decorations_area_canvas_y + 1 x00000044_left_decorations_area_canvas_height = 0
  c44: - 1 x00000007_plot_area_canvas_y + 1 x00000011_title_area_canvas_y >= 0
  c45: - 1 x00000007_plot_area_canvas_y - 1 x00000008_plot_area_canvas_height + 1 x00000039_bottom_left_decorations_area_canvas_y + 1 x00000040_bottom_left_decorations_area_canvas_height <= 0
  c46: 1 x00000011_title_area_canvas_y + 1 x00000012_title_area_canvas_height - 1 x00000019_top_decorations_area_canvas_y = 0
  c47: - 1 x00000015_data_area_canvas_y + 1 x00000019_top_decorations_area_canvas_y + 1 x00000020_top_decorations_area_canvas_height = 0
  c48: 1 x00000015_data_area_canvas_y + 1 x00000016_data_area_canvas_height - 1 x00000035_bottom_decorations_area_canvas_y = 0
  c49: - 1 x00000007_plot_area_canvas_y + 1 x00000011_title_area_canvas_y >= 0
  c5: 1 x00000019_top_decorations_area_canvas_y - 1 x00000023_top_right_decorations_area_canvas_y = 0
  c50: - 1 x00000007_plot_area_canvas_y - 1 x00000008_plot_area_canvas_height + 1 x00000035_bottom_decorations_area_canvas_y + 1 x00000036_bottom_decorations_area_canvas_height <= 0
  c51: 1 x00000011_title_area_canvas_y + 1 x00000012_title_area_canvas_height - 1 x00000023_top_right_decorations_area_canvas_y = 0
  c52: 1 x00000023_top_right_decorations_area_canvas_y + 1 x00000024_top_right_decorations_area_canvas_height - 1 x00000027_right_decorations_area_canvas_y = 0
  c53: 1 x00000027_right_decorations_area_canvas_y + 1 x00000028_right_decorations_area_canvas_height - 1 x00000031_bottom_right_decorations_area_canvas_y = 0
  c54: - 1 x00000007_plot_area_canvas_y + 1 x00000011_title_area_canvas_y >= 0
  c55: - 1 x00000007_plot_area_canvas_y - 1 x00000008_plot_area_canvas_height + 1 x00000031_bottom_right_decorations_area_canvas_y + 1 x00000032_bottom_right_decorations_area_canvas_height <= 0
  c56: - 1 x00000008_plot_area_canvas_height + 1 x00000012_title_area_canvas_height + 1 x00000016_data_area_canvas_height + 1 x00000020_top_decorations_area_canvas_height + 1 x00000036_bottom_decorations_area_canvas_height = 0
  c57: - 1 x00000009_plot_area_canvas_width + 1 x00000017_data_area_canvas_width + 1 x00000029_right_decorations_area_canvas_width + 1 x00000045_left_decorations_area_canvas_width = 0
  c58: 1 x00000052_x_axis_margin_end >= 7.086614173228346
  c59: 1 x00000051_x_axis_margin_start >= 7.086614173228346
  c6: - 1 x00000019_top_decorations_area_canvas_y - 1 x00000020_top_decorations_area_canvas_height + 1 x00000047_top_left_decorations_area_canvas_y + 1 x00000048_top_left_decorations_area_canvas_height = 0
  c60: 1 x00000062_x2_axis_margin_end >= 7.086614173228346
  c61: 1 x00000061_x2_axis_margin_start >= 7.086614173228346
  c62: 1 x00000057_y_axis_margin_end >= 7.086614173228346
  c63: 1 x00000056_y_axis_margin_start >= 7.086614173228346
  c64: 1 x00000067_y2_axis_margin_end >= 7.086614173228346
  c65: 1 x00000066_y2_axis_margin_start >= 7.086614173228346
  c66: 1 x00000002_plot_bounds_top = 2.25
  c67: - 1 x00000001_figure_height + 1 x00000003_plot_bounds_bottom = -2.25
  c68: 1 x00000004_plot_bounds_left = 2.25
  c69: - 1 x00000000_figure_width + 1 x00000005_plot_bounds_right = -2.25
  c7: 1 x00000019_top_decorations_area_canvas_y + 1 x00000020_top_decorations_area_canvas_height - 1 x00000023_top_right_decorations_area_canvas_y - 1 x00000024_top_right_decorations_area_canvas_height = 0
  c70: - 1 x00000010_title_area_canvas_x + 1 x00000070_plot_title_text_x = 0
  c71: - 1 x00000011_title_area_canvas_y - 1 x00000012_title_area_canvas_height + 1 x00000071_plot_title_text_y + 1 x00000074_plot_title_text_depth = -6
  c72: - 1 x00000011_title_area_canvas_y + 1 x00000071_plot_title_text_y - 1 x00000072_plot_title_text_height >= 0
  c73: - 1 x00000011_title_area_canvas_y - 1 x00000012_title_area_canvas_height + 1 x00000071_plot_title_text_y + 1 x00000074_plot_title_text_depth <= 0
  c74: - 1 x00000042_left_decorations_area_canvas_x - 1 x00000045_left_decorations_area_canvas_width + 1 x00000085_left_axis_canvas_canvas_x + 1 x00000088_left_axis_canvas_canvas_width = 0
  c75: - 1 x00000043_left_decorations_area_canvas_y + 1 x00000086_left_axis_canvas_canvas_y = 0
  c76: - 1 x00000044_left_decorations_area_canvas_height + 1 x00000087_left_axis_canvas_canvas_height = 0
  c77: - 1 x00000042_left_decorations_area_canvas_x - 1 x00000045_left_decorations_area_canvas_width + 1 x00000058_y_axis_x = 0
  c78: - 1 x00000043_left_decorations_area_canvas_y + 1 x00000059_y_axis_y = 0
  c79: 1 x00000055_y_axis_size + 1 x00000056_y_axis_margin_start + 1 x00000057_y_axis_margin_end - 1 x00000087_left_axis_canvas_canvas_height = 0
  c8: - 1 x00000015_data_area_canvas_y + 1 x00000043_left_decorations_area_canvas_y = 0
  c80: - 1 x00000042_left_decorations_area_canvas_x - 1 x00000045_left_decorations_area_canvas_width + 1 x00000089_labels_left_bound <= -4
  c81: 1 x00000080_text_x + 1 x00000083_text_width - 1 x00000089_labels_left_bound = -8
  c82: 1.0 x00000081_text_y - 0.5 x00000082_text_height + 0.5 x00000084_text_depth - 1.0 x00000086_left_axis_canvas_canvas_y - 0.5 x00000087_left_axis_canvas_canvas_height = 0
  c83: 1 x00000080_text_x - 1 x00000085_left_axis_canvas_canvas_x >= 0
  c84: 1 x00000080_text_x + 1 x00000083_text_width - 1 x00000085_left_axis_canvas_canvas_x - 1 x00000088_left_axis_canvas_canvas_width <= 0
  c85: - 1 x00000042_left_decorations_area_canvas_x - 1 x00000045_left_decorations_area_canvas_width + 1 x00000085_left_axis_canvas_canvas_x + 1 x00000088_left_axis_canvas_canvas_width <= 0
  c86: - 1 x00000042_left_decorations_area_canvas_x + 1 x00000085_left_axis_canvas_canvas_x >= 0
  c87: - 1 x00000021_top_decorations_area_canvas_width + 1 x00000093_top_axis_canvas_canvas_width = 0
  c88: - 1 x00000018_top_decorations_area_canvas_x + 1 x00000090_top_axis_canvas_canvas_x = 0
  c89: - 1 x00000019_top_decorations_area_canvas_y - 1 x00000020_top_decorations_area_canvas_height + 1 x00000091_top_axis_canvas_canvas_y + 1 x00000092_top_axis_canvas_canvas_height = 0
  c9: 1 x00000015_data_area_canvas_y - 1 x00000027_right_decorations_area_canvas_y = 0
  c90: - 1 x00000018_top_decorations_area_canvas_x + 1 x00000063_x2_axis_x = 0
  c91: - 1 x00000019_top_decorations_area_canvas_y - 1 x00000020_top_decorations_area_canvas_height + 1 x00000064_x2_axis_y = 0
  c92: - 1 x00000021_top_decorations_area_canvas_width + 1 x00000060_x2_axis_size + 1 x00000061_x2_axis_margin_start + 1 x00000062_x2_axis_margin_end = 0
  c93: - 1 x00000019_top_decorations_area_canvas_y - 1 x00000020_top_decorations_area_canvas_height + 1 x00000094_tick_label_baseline <= -7
  c94: - 1 x00000019_top_decorations_area_canvas_y - 1 x00000020_top_decorations_area_canvas_height + 1 x00000095_tick_label_bottom <= -7
  c95: - 1 x00000091_top_axis_canvas_canvas_y + 1 x00000095_tick_label_bottom >= 0
  c96: - 1 x00000019_top_decorations_area_canvas_y + 1 x00000091_top_axis_canvas_canvas_y >= 0
  c97: - 1 x00000019_top_decorations_area_canvas_y - 1 x00000020_top_decorations_area_canvas_height + 1 x00000091_top_axis_canvas_canvas_y + 1 x00000092_top_axis_canvas_canvas_height <= 0
  c98: - 1 x00000028_right_decorations_area_canvas_height + 1 x00000098_right_axis_canvas_canvas_height = 0
  c99: - 1 x00000026_right_decorations_area_canvas_x + 1 x00000096_right_axis_canvas_canvas_x = 0
Bounds
  0 <= x00000114_text_height
  0 <= x00000043_left_decorations_area_canvas_y
  0 <= x00000140_text_width
  0 <= x00000102_bottom_axis_canvas_canvas_y
  0 <= x00000046_top_left_decorations_area_canvas_x
  0 <= x00000082_text_height
  x00000132_text_x free
  x00000108_text_y free
  0 <= x00000078_text_width
  0 <= x00000034_bottom_decorations_area_canvas_x
  0 <= x00000100_labels_right_bound
  x00000053_x_axis_x free
  0.0 <= x00000055_y_axis_size
  0 <= x00000024_top_right_decorations_area_canvas_height
  0.0 <= x00000052_x_axis_margin_end
  x00000070_plot_title_text_x free
  0 <= x00000036_bottom_decorations_area_canvas_height
  0 <= x00000042_left_decorations_area_canvas_x
  0 <= x00000096_right_axis_canvas_canvas_x
  0 <= x00000006_plot_area_canvas_x
  0 <= x00000125_text_width
  0 <= x00000093_top_axis_canvas_canvas_width
  0 <= x00000021_top_decorations_area_canvas_width
  0.0 <= x00000056_y_axis_margin_start
  0.0 <= x00000066_y2_axis_margin_start
  0 <= x00000134_text_height
  0 <= x00000017_data_area_canvas_width
  0 <= x00000040_bottom_left_decorations_area_canvas_height
  x00000064_x2_axis_y free
  0 <= x00000104_bottom_axis_canvas_canvas_width
  x00000054_x_axis_y free
  0.0 <= x00000051_x_axis_margin_start
  x00000005_plot_bounds_right free
  x00000123_text_y free
  0 <= x00000072_plot_title_text_height
  0 <= x00000099_right_axis_canvas_canvas_width
  0 <= x00000015_data_area_canvas_y
  x00000118_text_y free
  0 <= x00000010_title_area_canvas_x
  x00000075_text_x free
  0 <= x00000129_text_height
  0 <= x00000141_text_depth
  x00000069_y2_axis_y free
  0 <= x00000098_right_axis_canvas_canvas_height
  x00000113_text_y free
  0 <= x00000037_bottom_decorations_area_canvas_width
  x00000002_plot_bounds_top free
  0 <= x00000087_left_axis_canvas_canvas_height
  0 <= x00000088_left_axis_canvas_canvas_width
  0.0 <= x00000061_x2_axis_margin_start
  x00000068_y2_axis_x free
  0.0 <= x00000067_y2_axis_margin_end
  0 <= x00000110_text_width
  0 <= x00000033_bottom_right_decorations_area_canvas_width
  x00000076_text_y free
  0 <= x00000035_bottom_decorations_area_canvas_y
  0 <= x00000101_bottom_axis_canvas_canvas_x
  x00000094_tick_label_baseline free
  x00000095_tick_label_bottom free
  0 <= x00000039_bottom_left_decorations_area_canvas_y
  0 <= x00000074_plot_title_text_depth
  113.38582677165354 <= x00000001_figure_height
  0.0 <= x00000062_x2_axis_margin_end
  0 <= x00000030_bottom_right_decorations_area_canvas_x
  0 <= x00000111_text_depth
  x00000106_tick_label_bottom free
  0 <= x00000085_left_axis_canvas_canvas_x
  x00000117_text_x free
  0 <= x00000109_text_height
  0 <= x00000016_data_area_canvas_height
  0 <= x00000047_top_left_decorations_area_canvas_y
  x00000133_text_y free
  0 <= x00000044_left_decorations_area_canvas_height
  x00000081_text_y free
  0 <= x00000097_right_axis_canvas_canvas_y
  0 <= x00000031_bottom_right_decorations_area_canvas_y
  0 <= x00000007_plot_area_canvas_y
  0 <= x00000009_plot_area_canvas_width
  0 <= x00000026_right_decorations_area_canvas_x
  0 <= x00000089_labels_left_bound
  0 <= x00000115_text_width
  x00000128_text_y free
  0 <= x00000022_top_right_decorations_area_canvas_x
  0 <= x00000038_bottom_left_decorations_area_canvas_x
  0 <= x00000028_right_decorations_area_canvas_height
  x00000071_plot_title_text_y free
  0 <= x00000086_left_axis_canvas_canvas_y
  0.0 <= x00000060_x2_axis_size
  0 <= x00000126_text_depth
  x00000058_y_axis_x free
  0 <= x00000045_left_decorations_area_canvas_width
  x00000112_text_x free
  0 <= x00000091_top_axis_canvas_canvas_y
  0 <= x00000012_title_area_canvas_height
  0 <= x00000048_top_left_decorations_area_canvas_height
  0.0 <= x00000050_x_axis_size
  x00000107_text_x free
  0 <= x00000020_top_decorations_area_canvas_height
  0 <= x00000025_top_right_decorations_area_canvas_width
  0 <= x00000131_text_depth
  0 <= x00000124_text_height
  0 <= x00000103_bottom_axis_canvas_canvas_height
  x00000059_y_axis_y free
  0 <= x00000079_text_depth
  0 <= x00000014_data_area_canvas_x
  0 <= x00000130_text_width
  0 <= x00000120_text_width
  0 <= x00000019_top_decorations_area_canvas_y
  0.0 <= x00000057_y_axis_margin_end
  0 <= x00000041_bottom_left_decorations_area_canvas_width
  0 <= x00000090_top_axis_canvas_canvas_x
  0 <= x00000023_top_right_decorations_area_canvas_y
  x00000063_x2_axis_x free
  0 <= x00000135_text_width
  x00000122_text_x free
  x00000127_text_x free
  0 <= x00000121_text_depth
  x00000003_plot_bounds_bottom free
  0 <= x00000119_text_height
  0 <= x00000018_top_decorations_area_canvas_x
  0 <= x00000092_top_axis_canvas_canvas_height
  x00000105_tick_label_baseline free
  0 <= x00000084_text_depth
  0 <= x00000029_right_decorations_area_canvas_width
  0 <= x00000083_text_width
  x00000080_text_x free
  0 <= x00000013_title_area_canvas_width
  0.0 <= x00000065_y2_axis_size
  0 <= x00000077_text_height
  0 <= x00000032_bottom_right_decorations_area_canvas_height
  0 <= x00000011_title_area_canvas_y
  0 <= x00000008_plot_area_canvas_height
  0 <= x00000073_plot_title_text_width
  0 <= x00000136_text_depth
  0 <= x00000139_text_height
  0 <= x00000049_top_left_decorations_area_canvas_width
  226.77165354330708 <= x00000000_figure_width
  x00000138_text_y free
  x00000004_plot_bounds_left free
  x00000137_text_x free
  0 <= x00000116_text_depth
  0 <= x00000027_right_decorations_area_canvas_y
General
End
