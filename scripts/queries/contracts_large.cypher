// Show contracts of a value larger than 10,000,000 USD
MATCH (k)-[:HAS_JURISDICTION]-(a:Company)<-[hc:HAS_CONTRACTOR]-(c:Contract)<-[i:ISSUES]-(b:Company)-[:HAS_JURISDICTION]-(j) WHERE TOINT(c.value_usd) > 10000000 RETURN c,a,hc,b,i