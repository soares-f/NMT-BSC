import requests
from bs4 import BeautifulSoup
import dataset
import time


def scrape_page(page_id,language):
    """
    Function to scrape individual pages from DermIS
    Inputs:
        -page_id: The ID of the disease
        -language: Language of interest
    Output: Dictionary with:
        -disease_name: Name of the disease (string)
        -disease_definition: Definition of the disease (string)
        -image_codes: Codes of the disease images (list of integers)
    """
    
    
    url_part1 = 'https://www.dermis.net/dermisroot/'
    url_part2 = '/diagnose.htm'
    
    # Download de page source
    disease_page = requests.get(url_part1 + language + '/' + str(page_id) + url_part2)
    
    # Parse to BS
    soup_disease = BeautifulSoup(disease_page.text,'html.parser')
    
    # Parse information
    disease_definition = soup_disease.find_all('p',attrs={'class': None})[0].text
    try:
        disease_name = soup_disease.find(class_='Container',attrs={'id': 'ctl00_Main_pnlMain'}).find('h2').text
    except:
        disease_name = ''
    
    # Parse images
    try:
        images_links = soup_disease.find(class_='Container',attrs={'id': 'ctl00_Main_pnlMain'}).find_all('a')
        
        image_codes = []
        for image in images_links:
            image_codes.append(image.get('href').split('/')[-2])
    except:
        images_codes = []
    


    
    result = {'disease_name': disease_name,
              'disease_definition': disease_definition,
              'image_codes': image_codes}
    
    return(result)


# Retrieve the main page with all diseases
main_page = requests.get('https://www.dermis.net/dermisroot/es/list/all/search.htm')
# Parse into a BS object
soup = BeautifulSoup(main_page.text,'html.parser')

# Get all diseases in a list
all_diseases = soup.find_all(class_='list')

# List for disease codes
codes = []
for disease in all_diseases:
    codes.append(disease.get('href').split('/')[-2])





db = dataset.connect('sqlite:///dermis.db')
table = db['scrapped']
languages = ['tr','jp','pt','es','fr','de','en']

for disease_code in codes:
    for language in languages:
        print(disease_code)
        tmp = scrape_page(disease_code, language)
        tmp['disease_code'] = disease_code
        tmp['language'] = language
        tmp['image_codes'] = ' '.join(tmp['image_codes'])
        table.insert(tmp)
        time.sleep(10)
        
        
