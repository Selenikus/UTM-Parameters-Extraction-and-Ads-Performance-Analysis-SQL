
    WITH combined_ads_data AS
    
    (SELECT 
    	fabd.campaign_id,
    	fc.campaign_name,
   		fabd.ad_date, 
    	fa.adset_name, 
    	fabd.url_parameters , 
    	coalesce (fabd.spend , 0) as spend,
    	coalesce (fabd.impressions , 0) as impressions,
    	coalesce (fabd.reach , 0) as reach,
    	coalesce (fabd.clicks ,0) as clicks,
    	coalesce (fabd.leads , 0) as leads,
    	coalesce (fabd.value ,0) as value
    
    FROM facebook_ads_basic_daily fabd
    INNER JOIN 
        facebook_adset fa ON fa.adset_id = fabd.adset_id
    INNER JOIN 
    	facebook_campaign fc on fc.campaign_id = fabd.campaign_id 
        
    UNION
    
 SELECT 
        fc.campaign_id, 
        gabd.campaign_name,
        gabd.ad_date,
        gabd.adset_name ,
        gabd.url_parameters ,
        coalesce (gabd.spend,0) as spend, 
        coalesce (gabd.impressions ,0) as impressions,
        coalesce (gabd.reach ,0) as reach,
        coalesce (gabd.clicks,0) as clicks,
        coalesce (gabd.leads,0) as leads,
        coalesce (gabd.value,0) as value
       
    FROM 
        google_ads_basic_daily gabd 
    INNER JOIN 
        facebook_campaign fc ON fc.campaign_name = gabd.campaign_name)
        
   SELECT
   
   ad_date,
   campaign_name,
   url_parameters,
   
  CASE 
    WHEN LOWER(SUBSTRING(url_parameters, 'utm_campaign=([^&#$]+)'))  = 'nan' 
    THEN NULL
    ELSE LOWER(SUBSTRING(url_parameters, 'utm_campaign=([^&#$]+)')) 
    end as utm_campaign,
   

    SUM(spend) as spend,
    SUM (impressions) as impressions,
    SUM(clicks) as clicks, 
    SUM(value) as value,
   
  CASE 
	WHEN sum(cast(impressions as decimal)) =0 THEN NULL 
	ELSE 
	round(sum(cast(clicks as decimal )) /sum(cast(impressions
	AS decimal )) * 100,2)
	END AS CTR,
	
  CASE WHEN
	sum(cast(clicks as decimal)) =0  THEN NULL
	ELSE
	ROUND(SUM(cast(spend as decimal))/ SUM(cast(clicks as decimal)),2)
	END AS CPC,
	
  CASE WHEN
	sum(cast(impressions as decimal))= 0 THEN NULL
	ELSE
	Round((Sum(cast(spend as decimal)) / sum(cast(impressions as decimal)))*1000,2) 
	END AS CPM,
	
	ROUND(((SUM(cast(value as decimal)) - sum(cast(spend as decimal))) / nullif(sum(cast(spend as decimal)),0))*100,2)
    AS ROMI
 
   FROM 
   	combined_ads_data cad
  
   GROUP BY 
  	ad_date, campaign_name, url_parameters
  	
   ORDER BY ad_date;
 

       













