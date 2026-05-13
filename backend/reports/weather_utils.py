import requests

def get_rainfall_forecast(lat, lng):
    """
    Fetches hourly rainfall forecast from Open-Meteo.
    Returns the sum of predicted rainfall for the next 6 hours.
    """
    url = "https://api.open-meteo.com/v1/forecast"
    params = {
        "latitude": lat,
        "longitude": lng,
        "hourly": "precipitation",
        "forecast_days": 1
    }
    
    try:
        response = requests.get(url, params=params, timeout=5)
        data = response.json()
        
        # Get next 6 hours of precipitation
        precip = data.get('hourly', {}).get('precipitation', [])[:6]
        return sum(precip)
    except Exception as e:
        print(f"Weather API error: {e}")
        return 0.0
