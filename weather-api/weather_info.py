#weather api simulation
import requests, json

API_KEY = '1d397744533d259f5bd232db5c8f0621'
API_KEY_PARAM = "&appid=" + API_KEY
FORECAST_URL = "https://api.openweathermap.org/data/2.5/forecast?"
CURRENT_TEMP_BASE_URL = "https://api.openweathermap.org/data/2.5/weather?"


def get_area_info_based_on_lat_and_lon(lat, lon):
    url = CURRENT_TEMP_BASE_URL + "lat=" + lat + "&lon=" + lon + API_KEY_PARAM
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        return {"metadata": {"id": data["id"], "name": data["name"], "lat":lat, "lon":lon}, "current_temp_info": data["main"]}
    else:
        print("Error in the HTTP request", response.json())


def fetch_current_weather_info(area_info):
        weather_data= area_info['current_temp_info']
        return {"city_name": area_info["metadata"]["name"], "lat" : area_info["metadata"]["lat"], "lon": area_info["metadata"]["lon"], "temperature" : weather_data['temp'],
                "humidity" : weather_data['humidity']}

def fetch_forecast_info(area_info):
    url = FORECAST_URL + "id="+ str(area_info["metadata"]["id"]) + API_KEY_PARAM
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        return {"city_name": area_info["metadata"]["name"], "lat" : area_info["metadata"]["lat"], "lon": area_info["metadata"]["lon"],
                "data" : data}
    else:
        print("Error in the HTTP request", response.json())

if __name__ == '__main__':
     area_info = get_area_info_based_on_lat_and_lon("26.449923", "80.331871")
     current_weather = fetch_current_weather_info(area_info)
     forecast_info= fetch_forecast_info(area_info)
     print(current_weather)
     print(forecast_info)



