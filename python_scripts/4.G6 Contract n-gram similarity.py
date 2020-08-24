# -*- coding: utf-8 -*-
"""
Created on Tue Mar  3 23:15:44 2020

@author: vathis
"""
import pandas as pd
import time
import os
os.chdir('C:\\Users\\vathi\\git\\capture-milla\\python_scripts')

from sklearn.feature_extraction.text import CountVectorizer
from nltk.tokenize.regexp import regexp_tokenize
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

ngram_range = (3,3)

#%% Import opcodes from bigquery

import bq_time_check_run as bss

opcodes_sql = 'SELECT opcode_str_wo_params FROM `capture-milla-259710.capture_milla.opcode_descriptives`'

usage_mbs, checktime = bss.check_usage(opcodes_sql)

opcodes_all, runtime = bss.run_query(opcodes_sql)

opcodes_all['opcode_str_wo_params'] = opcodes_all['opcode_str_wo_params'].str.replace(',',' ')

opcodes = opcodes_all

#%% Export opcodes to csv

opcodes_all.to_csv('opcodes_all.csv', sep=',', encoding='utf-8')

#%% -Optional- if data in .csv have already been downloaded: import from .csv

t1 = time.time()
#opcodes = pd.read_csv('opcodes_all.csv', index_col=0, header=0)
#opcodes = pd.read_csv('opcodes_all.csv', index_col=0, header=0, nrows=5000)
t2 = time.time()
tload = t2 - t1
print('Time to load',tload)


def renltk_tokenize(text):
    return regexp_tokenize(text,
                           pattern = '\s',
                           gaps = True)


# Tokenize and Vectorize the opcode tokens
oplist = list(opcodes.opcode_str_wo_params.values)
del opcodes

vect = CountVectorizer(max_features = None,
                     tokenizer = renltk_tokenize,
                     ngram_range = ngram_range,
                     lowercase = False)

t1 = time.time()
oplist_matrix = vect.fit_transform([np.str_(x) for x in oplist])
opcodes_n = len(oplist)
del oplist
t2 = time.time()
print('Tokenize/vectorize process time ',t2-t1)
print(oplist_matrix.shape)

terms = vect.get_feature_names()

# create clustered dictionary or load it from .csv

   
#optionally load the clusters from saved .csv

#loaded_clustered = pd.read_csv('all_clusters.csv',index_col='opcode')
#clustered = loaded_clustered.to_dict()['cluster']
#cluster_i = loaded_clustered['cluster'].max() + 1

#set the first opcode to its own cluster and keep the cluster no. for the next cluster

clustered = {0:0} # opcode:cluster
cluster_i = 1

clust_examp = {0:0} # cluster:example
#% the clustering...

i_was_clustered = False
ts = time.time()

for i in range(1,opcodes_n):
    
    for j_cluster,j in clust_examp.items():
        #print(i,j,j_cluster)
        similarity = cosine_similarity(oplist_matrix[(i,j),:])[0,1]
        #print(similarity)
        if similarity >= 0.90:
            clustered[i] = j_cluster
            i_was_clustered = True
            #print('clustered',i,'to',j_cluster)
            break
            
    if (i_was_clustered == False):
        clustered[i] = cluster_i
        clust_examp[cluster_i] = i
        cluster_i = cluster_i + 1
        print('clustered',i,'to new cluster',cluster_i)
    else:
        i_was_clustered = False
        
tc = time.time()
time_to_cluster = tc - ts
print('Time to cluster:',time_to_cluster)


#% save results

all_clusters = pd.DataFrame.from_dict(clustered,orient='index',columns=['cluster'])
all_clusters.index.names = ['opcode']
all_clusters.to_csv('clustered_b_' + str(ngram_range[0]) + '.csv')
all_clusters = all_clusters.reset_index()
all_clusters.describe()

opcodes_per_cluster = all_clusters.groupby('cluster')['cluster'].count()
opcodes_per_cluster.to_csv('opcodes per cluster b ' + str(ngram_range[0]) + '.csv')


































