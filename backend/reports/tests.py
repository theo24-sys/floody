from django.test import TestCase
from django.contrib.gis.geos import Point
from django.utils.timezone import now
from datetime import timedelta
from .models import FloodReport

class TrustEngineTest(TestCase):
    def setUp(self):
        self.device_id = "test_device"
        self.location = Point(36.8219, -1.2921) # Nairobi

    def test_report_verification(self):
        # Create 2 reports from different devices in the same area
        FloodReport.objects.create(
            device_id="device_1",
            location=self.location,
            category="flooded",
            status="pending"
        )
        FloodReport.objects.create(
            device_id="device_2",
            location=self.location,
            category="flooded",
            status="pending"
        )
        
        # Now current device reports
        report = FloodReport.objects.create(
            device_id=self.device_id,
            location=self.location,
            category="flooded"
        )
        
        # Verify manually (logic is in view, but we can test the query here)
        nearby_count = FloodReport.objects.filter(
            location__dwithin=(report.location, 0.005), # approx 500m
            timestamp__gte=now() - timedelta(hours=1)
        ).exclude(device_id=self.device_id).count()
        
        self.assertEqual(nearby_count, 2)
