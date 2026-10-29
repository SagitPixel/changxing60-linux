from pathlib import Path
p=Path('/k/linux/drivers/unisoc_platform/sprdwcn/platform/wcn_boot.c');s=p.read_text()
a=s.index('\tpmu_apb_gpr = syscon_regmap_lookup_by_phandle(np,',s.index('static int marlin_parse_dt'))
b=s.index('\n\treturn 0;\n}',a)
s=s[:a]+'\t/* Legacy boards leave crystal wait programming to WCN firmware.\n\t * Both endpoints must exist before we copy a PMU wait count to CP.\n\t */\n\tmarlin2_clk_wait_reg = 0;\n\tclk_wait_val = 0;\n\tif (of_property_read_u32(np, "sprd,reg-m2-apb-xtl-wait-addr",\n\t\t\t\t &marlin2_clk_wait_reg)) {\n\t\tdev_info(&pdev->dev, "legacy DT: keeping firmware crystal wait configuration\\n");\n\t\treturn 0;\n\t}\n\tpmu_apb_gpr = syscon_regmap_lookup_by_phandle(np, "sprd,syscon-pmu-apb");\n\tif (IS_ERR(pmu_apb_gpr))\n\t\treturn PTR_ERR(pmu_apb_gpr);\n\tret = regmap_read(pmu_apb_gpr, REG_PMU_APB_XTL_WAIT_CNT0, &clk_wait_val);\n\tif (ret)\n\t\treturn ret;\n'+s[b:];p.write_text(s)
