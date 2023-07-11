import pandas as pd
import numpy as np

pd.set_option('display.max_columns', None) #18 columns, None = all columns
# load the dataframe
path = "C:/Cytoscape_ONTOX_toy_model/sysrev_data/steatosis_raw_v7_09_06_2022.csv"
df_raw = pd.read_csv(path, on_bad_lines='skip', encoding='cp1252') #index_col=0
df_raw = df_raw.rename(columns={"ï»¿Article.ID": "Article.ID"})
# remove Leading and Trailing space of KE columns
df_raw['KE..Up.'] = df_raw['KE..Up.'].str.strip()
df_raw['KE.Down.'] = df_raw['KE.Down.'].str.strip()
print(df_raw.head())
print(list(df_raw.columns))


# create 'edge' column
df_raw["edge"] = df_raw[['KE..Up.', 'KE.Down.']].agg('-'.join, axis=1)
print(df_raw.head())
print(len(set(df_raw.edge))) #231

# subset dose dataframe and time dataframe
df_dose = df_raw[["Article.ID","edge", "Dose.concordance..EP."]]
df_time = df_raw[["Article.ID","edge", "Time.concordance..EP."]]
df_edge_time = df_time[["edge", "Time.concordance..EP."]]
### calculate the dose edges/nodes and the frequency
# count the number of unique edge
df_edge_dose = df_dose[["edge", "Dose.concordance..EP."]]
df_edge_count = df_edge_dose.groupby('edge').count()
df_edge_count = df_edge_count.rename(columns={"Dose.concordance..EP.": "edge_count"})
#df_dose_count = df_dose_count[['edge', "count"]]
print(type(df_edge_count))
print(df_edge_count.head())
print(df_edge_count.shape) #(226, 1)


### calculate the edge_Aid frequency
# count the number of unique edge
df_edge_Aid = df_dose[["Article.ID", "edge"]].drop_duplicates(ignore_index=True)
df_edge_Aid_count = df_edge_Aid.groupby('edge').count()
df_edge_Aid_count = df_edge_Aid_count.rename(columns={"Article.ID":"Aid_count"})
print(df_edge_Aid_count.head())
print(df_edge_Aid_count.shape) #(226, 1)

df_edgecount_Aidcount = pd.merge(left=df_edge_count, right=df_edge_Aid_count, left_index=True, right_index=True)
print(df_edgecount_Aidcount.head())
df_edgecount_Aidcount = df_edgecount_Aidcount.reset_index()
print(df_edgecount_Aidcount.shape) #(226, 3)

#path_df_edgecount_Aidcount = 'C:/Cytoscape_ONTOX_toy_model/sysrev_data/Steatosis_EE/full_script_documents_09_06_2022/edge_count_check.csv'
#df_edgecount_Aidcount.to_csv(path_df_edgecount_Aidcount, index=True)

# calculate the percentage of dose concordance of each edge
df_dose_gb = df_edge_dose.groupby('edge', as_index=False).value_counts(normalize=True)
print(df_dose_gb.shape) #((283, 3)
print(df_dose_gb.head())

# separate nomearsure rows (filtering data on basis of both filters : nomearsue and 100% proportion)
df_dose_nomeasure= df_dose_gb[(df_dose_gb['Dose.concordance..EP.'] == "nomeasure") &
                               (df_dose_gb['proportion'] == 1)]
print(df_dose_nomeasure.shape) #(130, 3)
print(len(set(df_dose_nomeasure.edge))) # 130
df_dose_nomeasure.loc[:,"dose_freq"] = 0
print(df_dose_nomeasure.head())
df_dose_nomeasure_score = df_dose_nomeasure[['edge','Dose.concordance..EP.', 'dose_freq']]
print(df_dose_nomeasure_score.head())

## prepare yes & no score ##
# remove the edge only contain nomeasure
df_dose_rest = df_dose_gb[~df_dose_gb.index.isin(df_dose_nomeasure.index.tolist())]
print(df_dose_rest.shape) #(153, 3)
print(df_dose_rest.head())

# remove the edge of nomeasure
df_dose_all_condition = df_dose_rest[df_dose_rest["Dose.concordance..EP."].str.contains("nomeasure") == False]
print(df_dose_all_condition.shape) #(107, 3)
print(df_dose_all_condition.head())
print(len(set(df_dose_all_condition.edge))) #96

# select edges containing both yes/no labels
df_dose_multiple_tests = df_dose_all_condition.groupby('edge').size().to_frame()
print(df_dose_multiple_tests.head())

dose_correct_list = df_dose_multiple_tests[df_dose_multiple_tests.iloc[:, 0] > 1].index.tolist()
print(len(dose_correct_list), dose_correct_list) #11

# calculate 'final yes percentage' (yes%-no%)
idx_dose = df_dose_all_condition[df_dose_all_condition["Dose.concordance..EP."] == 'no'].index
df_dose_all_condition.loc[idx_dose, 'proportion'] = df_dose_all_condition.loc[idx_dose, 'proportion'] * (-1)

df_dose_calculated_percentage = df_dose_all_condition.groupby(['edge'], as_index=False).agg({'Dose.concordance..EP.': 'min', 'proportion': 'sum'})
print(df_dose_calculated_percentage)

# rename the column
df_dose_calculated = df_dose_calculated_percentage.rename(columns={"proportion": "dose_freq"})
print(df_dose_calculated.head())

# re-organized info of 'Dose.concordance..EP.' column (label 'final yes percentage' column value using information in dose_correct_list)
df_dose_calculated.loc[:, 'dose'] = df_dose_calculated["edge"].apply(lambda x: "yes" if(x in dose_correct_list)
else df_dose_calculated.loc[df_dose_calculated["edge"] == x, 'Dose.concordance..EP.'].item())
print(df_dose_calculated.tail())

df_dose_check = df_dose_calculated[df_dose_calculated["edge"].isin(dose_correct_list)]
print(df_dose_check.shape) #(11, 4)

## write results for dose concordance
# generate dose concordance calculation results for edges containing yes & no score
df_dose_corrected = df_dose_calculated[['edge', 'dose', 'dose_freq']]
df_dose_corrected = df_dose_corrected.rename(columns={"dose": "Dose.concordance..EP."})
print(df_dose_corrected.shape) #(96, 3)

# integrate nomeasure results to dose concordance calculation results
df_dose_all = pd.concat([df_dose_nomeasure_score, df_dose_corrected], axis=0, ignore_index=True)
df_dose_all_count = pd.merge(df_dose_all, df_edgecount_Aidcount, on="edge")

print(df_dose_all_count.shape) # (226, 5)
print(df_dose_all_count.head(3))

### calculate the time edges/nodes and the frequency
print("calculate the time edges/nodes and the frequency")
# count the number of unique edge
df_time_count = df_edge_time.groupby('edge').count()
df_time_count = df_time_count.rename(columns={"Time.concordance..EP.":"time_count"})
#df_time_count = df_time_count[['edge', "count"]]
print(type(df_time_count))
print(df_time_count.head())
print(df_time_count.shape) #(226, 1)

# calculate the percentage of time concordance of each edge
df_time_gb = df_edge_time.groupby('edge', as_index=False).value_counts(normalize=True)
print(df_time_gb.shape) #(279, 3)
print(df_time_gb.head())

# separate nomearsure rows (filtering data on basis of both filters : nomearsue and 100% proportion)
df_time_nomeasure= df_time_gb[(df_time_gb['Time.concordance..EP.'] == "nomeasure") &
                               (df_time_gb['proportion'] == 1)]
print(df_time_nomeasure.shape) #(165, 3)
print(len(set(df_time_nomeasure.edge))) # 165
df_time_nomeasure.loc[:,"time_freq"] = 0
print(df_time_nomeasure.head())
df_time_nomeasure_score = df_time_nomeasure[['edge','Time.concordance..EP.', 'time_freq']]
print(df_time_nomeasure_score.head())

## prepare yes & no score ##
# remove the edge only contain nomeasure
df_time_rest = df_time_gb[~df_time_gb.index.isin(df_time_nomeasure.index.tolist())]
print(df_time_rest.shape) #(114, 3)
print(df_time_rest.head())

# remove the edge of nomeasure
df_time_all_condition = df_time_rest[df_time_rest["Time.concordance..EP."].str.contains("nomeasure") == False]
print(df_time_all_condition.shape) #(77, 3)
print(df_time_all_condition.head())
print(len(set(df_time_all_condition.edge))) #61

# select edges containing both yes/no labels
df_time_multiple_tests = df_time_all_condition.groupby('edge').size().to_frame()
print(df_time_multiple_tests.head())

time_correct_list = df_time_multiple_tests[df_time_multiple_tests.iloc[:, 0] > 1].index.tolist()
print(len(time_correct_list), time_correct_list) #16

# calculate 'final yes percentage' (yes%-no%)
idx_time = df_time_all_condition[df_time_all_condition["Time.concordance..EP."] == 'no'].index
df_time_all_condition.loc[idx_time, 'proportion'] = df_time_all_condition.loc[idx_time, 'proportion'] * (-1)

df_time_calculated_percentage = df_time_all_condition.groupby(['edge'], as_index=False).agg({'Time.concordance..EP.': 'min', 'proportion': 'sum'})
print(df_time_calculated_percentage)

#rename the column
df_time_calculated = df_time_calculated_percentage.rename(columns={"proportion": "time_freq"})
print(df_time_calculated.head())

# re-organized info of 'Time.concordance..EP.' column (label 'final yes percentage' column value using information in time_correct_list)
df_time_calculated.loc[:, 'time'] = df_time_calculated["edge"].apply(lambda x: "yes" if(x in time_correct_list)
else df_time_calculated.loc[df_time_calculated["edge"] == x, 'Time.concordance..EP.'].item())
print(df_time_calculated.tail())

df_time_check = df_time_calculated[df_time_calculated["edge"].isin(time_correct_list)]
print(df_time_check.shape) #(16, 4)

## write results for time concordance
# generate time concordance calculation results for edges containing yes & no score
df_time_corrected = df_time_calculated[['edge', 'time', 'time_freq']]
df_time_corrected = df_time_corrected.rename(columns={"time": "Time.concordance..EP."})
print(df_time_corrected.shape) #(61, 3)

# integrate nomeasure results to time concordance calculation results
df_time_all = pd.concat([df_time_nomeasure_score, df_time_corrected], axis=0, ignore_index=True)
df_time_all_count = pd.merge(df_time_all, df_time_count, on="edge")

print(df_time_all_count.shape) # (226, 4)
print(df_time_all_count.head(3))


dose_set=set(df_dose_all_count['edge'].tolist())
time_set=set(df_time_all_count['edge'].tolist())
print(dose_set.difference(time_set)) # set()

## concatenate time/dose concordance results
df_all = df_time_all_count.merge(df_dose_all_count, how="left")
df_all = df_all.reset_index(drop=True)
print(df_all.head())
print(df_all.shape)#(226, 8)


# write file
#path_df_time_dose = 'C:/Cytoscape_ONTOX_toy_model/sysrev_data/Steatosis_EE/full_script_documents_09_06_2022/steatosis_time_dose_freq_count.csv'
#df_all.to_csv(path_df_time_dose)

## calculate the weight of edge
# calculate time/dose score
df_all['time_score'] = df_all['time_freq'] * df_all['time_count']
df_all['dose_score'] = df_all['dose_freq'] * df_all['edge_count']
print(df_all.head())
# rank time score low: x <=0, middle: 0<x<quantile(0.8), high:x>=quantile(0.8) (middle and high are the ranks of all above 0 values)
df_all.loc[:, "time_score_positive"] = df_all['time_score'].apply(lambda x: x if (x >= 0) else 0)
print(df_all.head())
print(df_all.tail())
df_all.loc[:, "time_score_rank"] = abs(df_all['time_score_positive'].replace(0, np.nan, inplace=False)).rank()
print(df_all.head())
print(df_all.tail())
print(df_all["time_score_rank"].quantile([0.50, 0.75, 0.8, 0.85, 0.9]))
# 0.50    12.0
# 0.75    12.0
# 0.80    25.0
# 0.85    25.0
# 0.90    28.0

time_quantile_filter = df_all["time_score_rank"].quantile(0.8)
print(time_quantile_filter)

df_all["time_score_rank"] = df_all["time_score_rank"].fillna(0)
print(set(df_all["time_score_rank"]))
# {0.0, 12.0, 25.0, 28.0, 30.0}

def condition_time(x):
    if x >= time_quantile_filter: #df_all["time_score_rank"].quantile(0.8)
        return "high"
    elif x <= 0:
        return "low"
    else:
        return 'middle'
df_all.loc[:, "time_rank"] = df_all["time_score_rank"].apply(condition_time)
print(df_all.head(3))



# rank dose score low: x <=0, middle: 0<x<quantile(0.8), high:x>=quantile(0.8) (middle and high are the ranks of all above 0 values)
df_all.loc[:, "dose_score_positive"] = df_all['dose_score'].apply(lambda x: x if (x >= 0) else 0)
print(df_all.head())
print(df_all.tail())
df_all.loc[:, "dose_score_rank"] = abs(df_all['dose_score_positive'].replace(0, np.nan, inplace=False)).rank()
print(df_all.head())
print(df_all.tail())
print(df_all["dose_score_rank"].quantile([0.50, 0.75, 0.8, 0.85, 0.9]))
# 0.50    21.500
# 0.75    60.000
# 0.80    65.000
# 0.85    65.675
# 0.90    71.750
dose_quantile_filter = df_all["dose_score_rank"].quantile(0.8)
print(dose_quantile_filter)
df_all["dose_score_rank"] = df_all["dose_score_rank"].fillna(0)
print(set(abs(df_all['dose_score_rank']).tolist()))
# {0.0, 65.0, 69.5, 71.5, 74.0, 43.0, 76.0, 78.0, 80.0, 51.0, 21.5, 60.0}
def condition_dose(x):
    if x >= dose_quantile_filter: #df_all["dose_score_rank"].quantile(0.8)
        return "high"
    elif x <= 0:
        return "low"
    else:
        return 'middle'
df_all.loc[:, "dose_rank"] = df_all["dose_score_rank"].apply(condition_dose)
print(df_all.head(3))

# assign values to time/dose ranks: low == 1, middle ==2, high ==3
def condition(x):
    if x == "low":
        return 1
    elif x == "middle":
        return 2
    else:
        return 3

df_all.loc[:, "dose_rank_score"] = df_all["dose_rank"].apply(condition)
df_all.loc[:, "time_rank_score"] = df_all["time_rank"].apply(condition)

# calculate EE of each edge sore by adding up time/dose values
df_all['EE_score'] = df_all['dose_rank_score'] + df_all['time_rank_score']
# write file
#path_df_all = 'C:/Cytoscape_ONTOX_toy_model/sysrev_data/Steatosis_EE/full_script_documents_09_06_2022/steatosis_time_dose_rank_score.csv'
#df_all.to_csv(path_df_all, index=False)

## prepare edge weight(EE score) and node size node freq (for Cytoscape input)-all edges/nodes
df_edge = df_all[['edge','EE_score']]
print(df_edge.head())
df_edge[['source', 'target']] = df_edge['edge'].str.split('-', expand=True)
print(df_edge.head())

df_edge_ready = df_edge[['source', 'target', 'EE_score']]
df_edge_ready = df_edge_ready.rename(columns={"EE_score":"weight"})
print(df_edge_ready.head())
print(df_edge_ready.shape) #(226, 3)
# write file
# path_df_edge_ready = 'C:/Cytoscape_ONTOX_toy_model/sysrev_data/Steatosis_EE/full_script_documents_09_06_2022/steatosis_EE_edge_weight.csv'
# df_edge_ready.to_csv(path_df_edge_ready, index=False)

# prepare the nodes size document
df_raw_nodes = df_raw[['KE..Up.', 'KE.Down.', 'Dose.concordance..EP.','Time.concordance..EP.']]

df_node_all2 = pd.concat([df_raw_nodes[['KE..Up.']], df_raw_nodes[['KE.Down.']]], axis=1)
print(df_node_all2.head())
print(df_node_all2.shape)
df_node_stack = df_node_all2.stack().to_frame()
print(df_node_stack.head())
print(df_node_stack.shape) #(1836, 1)
df_node_stack.columns = ["node"]
print(df_node_stack.head())
print(df_node_stack.node.value_counts(normalize=True))
print(df_node_stack.node.value_counts())
# liver_triglyceride_accumulation                      510
# de_novo_lipogenesis_fa_synthesis                     197
# steatosis                                            186
# mitochondrial_beta_oxidation                         119
# fa_uptake                                             78
print(type(df_node_stack.node.value_counts(normalize=True)))
df_whole_nodes_rank = df_node_stack.node.value_counts(normalize=True).to_frame()
print(df_whole_nodes_rank.head())
print(df_whole_nodes_rank.shape) #(102, 1)
df_whole_nodes_rank = df_whole_nodes_rank.reset_index()
print(df_whole_nodes_rank.head())
df_whole_nodes_rank.columns = ['id', 'freq']
print(df_whole_nodes_rank.head())
print(df_whole_nodes_rank.shape) #(102, 2)
# write file
# path_df_whole_nodes_rank = 'C:/Cytoscape_ONTOX_toy_model/sysrev_data/Steatosis_EE/full_script_documents_09_06_2022/steatosis_EE_whole_nodes_rank.csv'
# df_whole_nodes_rank.to_csv(path_df_whole_nodes_rank, index=False)



## prepare edge weight(EE score) and node size node freq (for Cytoscape input)-edge Aid_count value > 4
# subset edge count value > 4 dataframe
print(df_all["Aid_count"].quantile([0.6, 0.7,0.75, 0.8, 0.85, 0.9])) #1.0
# 0.60    1.0
# 0.70    1.0
# 0.75    1.0
# 0.80    1.0
# 0.85    2.0
# 0.90    4.0
df_countFliter = df_all[df_all['Aid_count'] >= df_all["Aid_count"].quantile(0.9)]

print(df_countFliter.head(3))
print(df_countFliter.shape) #(28, 19)


df_countFliter_edge = df_countFliter[['edge', 'EE_score']]
print(df_countFliter_edge.head(3))
df_countFliter_edge[['source', 'target']] = df_countFliter_edge['edge'].str.split('-', expand=True)
print(df_countFliter_edge.head(3))
print(df_countFliter_edge.shape) #(28, 4)

df_countFliter_edge_ready = df_countFliter_edge[['source', 'target', 'EE_score']]
df_countFliter_edge_ready = df_countFliter_edge_ready.rename(columns={"EE_score":"weight"})
print(df_countFliter_edge_ready)
print(df_countFliter_edge_ready.shape) # (28, 3)
# write file
# path_df_countFliter_edge_ready = 'C:/Cytoscape_ONTOX_toy_model/sysrev_data/Steatosis_EE/full_script_documents_09_06_2022/steatosis_EE_countFliter_edge_weight.csv'
# df_countFliter_edge_ready.to_csv(path_df_countFliter_edge_ready, index=False)

df_countFliter_all = pd.merge(df_raw_nodes, df_countFliter_edge_ready,  how='left', left_on=['KE..Up.','KE.Down.'], right_on = ['source', 'target'])
print(df_countFliter_all)
df_countFliter_dropna = df_countFliter_all.dropna()
print(df_countFliter_dropna.head())
print(df_countFliter_dropna.shape) #((543, 7)

df_countFliter_nodes = pd.concat([df_countFliter_dropna[['source']], df_countFliter_dropna[['target']]], axis=1)
df_countFliter_nodes_stack = df_countFliter_nodes.stack().to_frame()
df_countFliter_nodes_stack.columns = ["node"]
df_countFliter_nodes_rank = df_countFliter_nodes_stack.node.value_counts(normalize=True).to_frame()
df_countFliter_nodes_rank = df_countFliter_nodes_rank.reset_index()
df_countFliter_nodes_rank.columns = ['id', 'freq']
print(df_countFliter_nodes_rank.shape) #(17, 2)

#path_df_countFliter_nodes_rank = 'C:/Cytoscape_ONTOX_toy_model/sysrev_data/Steatosis_EE/full_script_documents_09_06_2022/steatosis_EE_countFliter_node_rank.csv'
#df_countFliter_nodes_rank.to_csv(path_df_countFliter_nodes_rank, index=False

# countFliter nodes in whole nodes rank
df_countFliter_original_rank = pd.merge(df_whole_nodes_rank, df_countFliter_nodes_rank,  how='left', left_on=['id'], right_on = ['id'])
print(df_countFliter_original_rank.head())
print(df_countFliter_original_rank.shape) #(102, 3)
df_countFliter_original_rank = df_countFliter_original_rank.dropna()
print(df_countFliter_original_rank.head())
print(df_countFliter_original_rank.shape) #(17, 3)

df_countFliter_original_rank = df_countFliter_original_rank.iloc[:, 0:2]
df_countFliter_original_rank.columns = ['id', 'freq']
print(df_countFliter_original_rank.head())
print(df_countFliter_original_rank.shape) #(17, 2)
# write file
# path_df_countFliter_original_rank = 'C:/Cytoscape_ONTOX_toy_model/sysrev_data/Steatosis_EE/full_script_documents_09_06_2022/steatosis_EE_countFliter_nodes_inoriginalrank.csv'
# df_countFliter_original_rank.to_csv(path_df_countFliter_original_rank, index=False)

