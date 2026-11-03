# Data Dictionary (schema `dw`)

| Object | Column | Type | Nullable | Description |
|---|---|---|---|---|
md_row                                                        
--------------------------------------------------------------
| dim_date | date_key | int | N | |                           
| dim_date | full_date | date | N | |                         
| dim_date | year_num | smallint | N | |                      
| dim_date | quarter_num | tinyint | N | |                    
| dim_date | month_num | tinyint | N | |                      
| dim_date | month_name | nvarchar(20) | N | |                
| dim_date | day_of_month | tinyint | N | |                   
| dim_date | weekday_num | tinyint | N | |                    
| dim_date | weekday_name | nvarchar(20) | N | |              
| dim_date | is_weekend | bit | N | |                         
| dim_date | fiscal_year | smallint | N | |                   
| dim_encounter_class | class_key | int | N | |               
| dim_encounter_class | class_code | nvarchar(50) | N | |     
| dim_encounter_class | class_name | nvarchar(100) | N | |    
| dim_encounter_class | class_group | nvarchar(50) | N | |    
| dim_organization | organization_key | int | N | |           
| dim_organization | organization_id | nvarchar(50) | N | |   
| dim_organization | organization_name | nvarchar(300) | N | |
| dim_organization | city | nvarchar(100) | Y | |             
| dim_organization | state | nvarchar(50) | Y | |             
| dim_organization | org_type | nvarchar(50) | N | |          
| dim_patient | patient_key | int | N | |                     
| dim_patient | patient_id | nvarchar(50) | N | |             
| dim_patient | gender | nvarchar(10) | Y | |                 
| dim_patient | birth_date | date | Y | |                     
| dim_patient | death_date | date | Y | |                     
| dim_patient | race | nvarchar(50) | Y | |                   
| dim_patient | ethnicity | nvarchar(50) | Y | |              
| dim_patient | marital_status | nvarchar(10) | Y | |         
| dim_patient | city | nvarchar(100) | Y | |                  
| dim_patient | county | nvarchar(100) | Y | |                
| dim_patient | state | nvarchar(100) | Y | |                 
| dim_provider | provider_key | int | N | |                   
| dim_provider | provider_id | nvarchar(50) | N | |           
| dim_provider | provider_name | nvarchar(200) | Y | |        
| dim_provider | specialty | nvarchar(200) | Y | |            
| dim_provider | gender | nvarchar(10) | Y | |                
| fact_encounter | encounter_key | int | N | |                
| fact_encounter | encounter_id | nvarchar(50) | N | |        
| fact_encounter | patient_key | int | N | |                  
| fact_encounter | provider_key | int | N | |                 
| fact_encounter | organization_key | int | N | |             
| fact_encounter | class_key | int | N | |                    
| fact_encounter | start_date_key | int | N | |               
| fact_encounter | start_datetime | datetime2 | N | |         
| fact_encounter | stop_datetime | datetime2 | Y | |          
| fact_encounter | los_hours | int | Y | |                    
| fact_encounter | los_minutes | int | Y | |                  
| fact_encounter | los_days | numeric | Y | |                 
| fact_encounter | total_claim_cost | decimal | Y | |         
| fact_encounter | reason_description | nvarchar(500) | Y | | 
| fact_encounter | is_outlier | bit | N | |                   
| sim_ed_pia | encounter_key | int | N | |                    
| sim_ed_pia | encounter_id | nvarchar(50) | N | |            
| sim_ed_pia | start_datetime | datetime2 | N | |             
| sim_ed_pia | arrival_hour | int | Y | |                     
| sim_ed_pia | arrival_month | int | Y | |                    
| sim_ed_pia | weekday_num | int | Y | |                      
| sim_ed_pia | los_minutes | int | Y | |                      
| sim_ed_pia | sim_pia_minutes | int | Y | |                  
| sim_ed_pia | data_source_flag | varchar | N | |             
| v_inpatient_episode | patient_key | int | N | |             
| v_inpatient_episode | episode_no | int | Y | |              
| v_inpatient_episode | n_encounters | int | Y | |            
| v_inpatient_episode | admit_datetime | datetime2 | Y | |    
| v_inpatient_episode | discharge_datetime | datetime2 | Y | |
| v_inpatient_episode | los_hours | int | Y | |               
| v_kpi_ed | encounter_key | int | N | |                      
| v_kpi_ed | start_datetime | datetime2 | N | |               
| v_kpi_ed | start_date_key | int | N | |                     
| v_kpi_ed | arrival_year | int | Y | |                       
| v_kpi_ed | arrival_hour | int | Y | |                       
| v_kpi_ed | ed_los_minutes | int | Y | |                     
| v_kpi_ed | is_outlier | bit | N | |                         
| v_kpi_ed | sim_pia_minutes | int | Y | |                    
| v_kpi_ed | pia_source_flag | varchar | N | |                
| v_kpi_inpatient_los | patient_key | int | N | |             
| v_kpi_inpatient_los | episode_no | int | Y | |              
| v_kpi_inpatient_los | n_encounters | int | Y | |            
| v_kpi_inpatient_los | admit_datetime | datetime2 | Y | |    
| v_kpi_inpatient_los | discharge_datetime | datetime2 | Y | |
| v_kpi_inpatient_los | discharge_year | int | Y | |          
| v_kpi_inpatient_los | discharge_date_key | int | Y | |      
| v_kpi_inpatient_los | los_days | numeric | Y | |            
| v_kpi_readmission | patient_key | int | N | |               
| v_kpi_readmission | episode_no | int | Y | |                
| v_kpi_readmission | discharge_year | int | Y | |            
| v_kpi_readmission | discharge_datetime | datetime2 | Y | |  
| v_kpi_readmission | days_to_next_admit | int | Y | |        
| v_kpi_readmission | is_readmit_30d | int | N | |            
| v_kpi_readmission | discharge_date_key | int | Y | |        
| v_readmission | patient_key | int | N | |                   
| v_readmission | episode_no | int | Y | |                    
| v_readmission | admit_datetime | datetime2 | Y | |          
| v_readmission | discharge_datetime | datetime2 | Y | |      
| v_readmission | discharge_year | int | Y | |                
| v_readmission | next_admit_datetime | datetime2 | Y | |     
| v_readmission | days_to_next_admit | int | Y | |            
| v_readmission | is_readmit_30d | int | N | |  
## Object roles
| Object | Role |
|---|---|
| dim_* | Dimension tables, surrogate integer keys, row -1 = Unknown |
| fact_encounter | Fact table, one row per encounter, grain = encounter |
| v_inpatient_episode | Merged inpatient episodes (gaps-and-islands, 24h rule) |
| v_readmission | Index discharges with next-admission lookup (LEAD) |
| sim_ed_pia | SIMULATED PIA, deterministic hash noise |
| v_kpi_* | Final KPI views consumed by Power BI; scope and exclusions defined here only |