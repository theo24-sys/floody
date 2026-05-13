from rest_framework import serializers
from django.contrib.gis.geos import Point
from .models import FloodReport

class FloodReportSerializer(serializers.ModelSerializer):
    lat = serializers.FloatField(write_only=True)
    lng = serializers.FloatField(write_only=True)

    class Meta:
        model = FloodReport
        fields = ['id', 'device_id', 'lat', 'lng', 'category', 'status', 'timestamp']
        read_only_fields = ['status', 'timestamp']

    def create(self, validated_data):
        lat = validated_data.pop('lat')
        lng = validated_data.pop('lng')
        validated_data['location'] = Point(lng, lat)
        return super().create(validated_data)
