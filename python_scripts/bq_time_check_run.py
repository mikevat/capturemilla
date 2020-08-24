from google.cloud import bigquery
auth_file = '../config/capture-milla-pk.json'
project = 'capture-milla-259710'

import time

def timeit(method):
    def timed(*args, **kw):
        ts = time.time()
        result = method(*args, **kw)
        te = time.time()
        if 'log_time' in kw:
            name = kw.get('log_name', method.__name__.upper())
            kw['log_time'][name] = int((te - ts) * 1)
        else:
            pass
        return result, (te - ts) * 1
    return timed

@timeit
def check_usage(query,log_time=0):
    client = bigquery.Client.from_service_account_json(auth_file,project=project)
    
    job_config = bigquery.QueryJobConfig()
    job_config.dry_run = True
    job_config.use_query_cache = False

    query_job = client.query(query
                            ,job_config=job_config)  # API request

    assert query_job.state == "DONE"
    assert query_job.dry_run

    processed_mb = query_job.total_bytes_processed/1000000
    print("This query will process {} Mbytes.".format(processed_mb))
    
    return processed_mb

@timeit
def run_query(query):
    client = bigquery.Client.from_service_account_json(auth_file,project=project)
    query_job = client.query(query)
    query_job = query_job.result()
    
    return query_job.to_dataframe()