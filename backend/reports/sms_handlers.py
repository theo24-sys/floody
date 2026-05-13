import json
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.gis.geos import Point
from .models import FloodReport

@csrf_exempt
def africastalking_sms_callback(request):
    if request.method == 'POST':
        from_number = request.POST.get('from')
        text = request.POST.get('text')
        
        # Example format: "FLOOD RISING TURKANA" or "FLOOD VERIFIED 123"
        parts = text.upper().split()
        
        if len(parts) >= 2 and parts[0] == 'FLOOD':
            category = parts[1].lower()
            location_name = parts[2] if len(parts) > 2 else "Unknown"
            
            # Since SMS has no GPS, we'd typically map "TURKANA" to a centroid
            # For this demo, we'll just log it or use a default
            location = Point(35.6, 3.1) # Lodwar centroid
            
            FloodReport.objects.create(
                device_id=f"sms_{from_number}",
                location=location,
                category=category if category in ['rising', 'flooded', 'receding'] else 'flooded',
                status='pending'
            )
            
        return HttpResponse("OK", status=200)
    return HttpResponse("Invalid request", status=400)
