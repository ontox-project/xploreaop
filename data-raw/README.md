## This folder contain raw data, meaning data recieved 'as-is'.

The subfolders contain the different datsets associated to this project:

./XPloreAOP/data-raw
├── D010
│   ├── BP_countFliter_edge_weight_10_01_2022.csv
│   ├── BP_countFliter_nodes_inoriginalrank_10_01_2022.csv
│   ├── BP_rank_10_01_2022.csv
│   ├── Steatosis_sumNscore_countFliter_edge_weight_10_01_2022.csv
│   ├── steatosis_EE_countFliter_edge_weight_10_01_2022.csv
│   ├── steatosis_EE_countFliter_nodes_inoriginalrank_10_01_2022.csv
│   ├── steatosis_EE_time_dose_rank_score_10_01_2022.csv
│   ├── steatosis_ESS_countFliter_edge_weight_10_01_2022.csv
│   ├── steatosis_ESS_countFliter_nodes_inoriginalrank_10_01_2022.csv
│   ├── steatosis_ESS_rank_10_01_2022.csv
│   └── steatosis_sumNscore_10_01_2022.csv
|
├── D020
│   ├── BP_countFliter_edge_weight_10_01_2022.csv
│   ├── BP_countFliter_nodes_inoriginalrank_10_01_2022.csv
│   ├── BP_rank_10_01_2022.csv
│   ├── aid_count_jonas.csv
│   ├── cholestasis_EE_all_edges_weight_3_10_2022.csv
│   ├── cholestasis_EE_all_nodes_rank_3_10_2022.csv
│   ├── cholestasis_EE_countFliter_edge_weight_3_10_2022.csv
│   ├── cholestasis_EE_countFliter_nodes_inoriginalrank_3_10_2022.csv
│   ├── cholestasis_ESS_Aid_peredge.csv
│   ├── cholestasis_ESS_countFliter_edge_weight_10_01_2022.csv
│   ├── cholestasis_ESS_countFliter_nodes_inoriginalrank_10_01_2022.csv
│   ├── cholestasis_ESS_rank_10_01_2022.csv
│   ├── cholestasis_cor_assay_score.csv
│   ├── cholestasis_grouped_data_08_11_22.csv
│   ├── cholestasis_sumNscore_10_01_2022.csv
│   ├── cholestasis_sumNscore_countFliter_edge_weight_10_01_2022.csv
│   ├── cholestasis_time_dose_freq_count_3_10_2022.csv
│   ├── cholestasis_time_dose_rank_score_3_10_2022.csv
│   ├── corr_pro_count.csv
│   ├── edge_count_check.csv
│   └── nlevel_results.csv
├── DATASET.R
├── README.md
└── external-data-info.csv

Python Scripts that generated or use some of these files can be found in: 

./XPloreAOP/inst
├── ONTOX_steatosis_EE_Aidcount4.cys
├── ONTOX_steatosis_EE_Aidcount4.png
├── aop_cholestasis_final2.cys
├── cholestasis_step0_ee_scoring.py
├── cholestasis_step1_ess_scoring.py
├── cholestasis_step2_bp_scoring.py
├── cholestasis_step3_tot_scoring.py
└── exploration.R
