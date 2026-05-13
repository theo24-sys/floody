from datetime import timedelta
from django.utils.timezone import now
from django.contrib.gis.measure import D
from django.views.generic import TemplateView
from rest_framework import status, generics
from rest_framework.views import APIView
from rest_framework.response import Response
from django.core.cache import cache
from django.contrib.gis.geos import Point
from .models import FloodReport
from .serializers import FloodReportSerializer
from .utils import export_reports_to_csv, generate_sitrep_pdf

class ReportCreateView(APIView):
    def post(self, request):
        serializer = FloodReportSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        device_id = serializer.validated_data['device_id']
        lat = serializer.validated_data['lat']
        lng = serializer.validated_data['lng']
        current_point = Point(lng, lat)
        
        # 1. Device Cooldown Check
        # Check if this device has submitted a report in the last 10 minutes for this cluster (500m)
        recent_report_by_device = FloodReport.objects.filter(
            device_id=device_id,
            location__dwithin=(current_point, D(m=500)),
            timestamp__gte=now() - timedelta(minutes=10)
        ).exists()
        
        if recent_report_by_device:
            return Response(
                {"error": "Cooldown active. Please wait 10 minutes before reporting in the same area."},
                status=status.HTTP_429_TOO_MANY_REQUESTS
            )

        report = serializer.save()
        
        # 2. Trust Engine: Count nearby reports in last hour (excluding current device)
        nearby_count = FloodReport.objects.filter(
            location__dwithin=(report.location, D(m=500)),
            timestamp__gte=now() - timedelta(hours=1)
        ).exclude(device_id=device_id).count()
        
        if nearby_count >= 2:  # 2 others + this one = 3 total
            report.status = 'verified'
            report.save()
            # Invalidate cache
            cache.delete('verified_reports_geojson')
            # TODO: Trigger FCM alert
            
        return Response(serializer.data, status=status.HTTP_201_CREATED)

class ReportListView(generics.ListAPIView):
    serializer_class = FloodReportSerializer

    def get_queryset(self):
        return FloodReport.objects.filter(status='verified')

    def list(self, request, *args, **kwargs):
        # Check cache first
        cached_data = cache.get('verified_reports_geojson')
        if cached_data:
            return Response(cached_data)

        response = super().list(request, *args, **kwargs)
        # Transform to simple GeoJSON-like structure for the heatmap
        geojson = {
            "type": "FeatureCollection",
            "features": [
                {
                    "type": "Feature",
                    "geometry": {
                        "type": "Point",
                        "coordinates": [r['lng'], r['lat']]
                    },
                    "properties": {
                        "category": r['category'],
                        "timestamp": r['timestamp']
                    }
                } for r in response.data
            ]
        }
        cache.set('verified_reports_geojson', geojson, timeout=3600) # Cache for 1 hour
        return Response(geojson)

class DashboardView(TemplateView):
    template_name = 'reports/dashboard.html'

class ExportReportsView(generics.GenericAPIView):
    def get(self, request, *args, **kwargs):
        queryset = FloodReport.objects.filter(status='verified')
        return export_reports_to_csv(queryset)

class SitrepPDFView(generics.GenericAPIView):
    def get(self, request, pk):
        return generate_sitrep_pdf(pk)

class ConfirmReportView(APIView):
    def post(self, request, pk):
        report = FloodReport.objects.get(pk=pk)
        device_id = request.data.get('device_id')
        
        if not device_id:
            return Response({"error": "device_id is required"}, status=400)
            
        if device_id not in report.confirmations:
            report.confirmations.append(device_id)
            # If a report gets 2 confirmations, it also triggers verification
            if len(report.confirmations) >= 2:
                report.status = 'verified'
            report.save()
            cache.delete('verified_reports_geojson')
            
        return Response({"status": report.status, "confirmations": len(report.confirmations)})

    # Helper for serializer Point creation if needed here, 
    # but serializer already handles it in .save() -> .create()
    # Let's adjust the logic slightly to avoid double point creation
