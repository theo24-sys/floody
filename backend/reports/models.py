from django.contrib.gis.db import models

class FloodReport(models.Model):
    CATEGORY_CHOICES = [
        ('rising', 'Rising'),
        ('flooded', 'Flooded'),
        ('receding', 'Receding'),
    ]
    
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('verified', 'Verified'),
    ]

    SEVERITY_CHOICES = [
        ('ankle', 'Ankle Deep'),
        ('knee', 'Knee Deep'),
        ('waist', 'Waist Deep'),
        ('above', 'Above Waist'),
    ]

    device_id = models.CharField(max_length=64)  # Hashed android_id
    location = models.PointField()
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES)
    severity = models.CharField(max_length=20, choices=SEVERITY_CHOICES, null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    image = models.ImageField(upload_to='reports/', null=True, blank=True)
    is_manual = models.BooleanField(default=False)
    confirmations = models.JSONField(default=list)  # List of device_ids
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.category} at {self.location} ({self.status})"
