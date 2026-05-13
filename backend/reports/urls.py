from django.urls import path
from .views import ReportCreateView, ReportListView, DashboardView, ExportReportsView, ConfirmReportView, SitrepPDFView
from .sms_handlers import africastalking_sms_callback

urlpatterns = [
    path('report/', ReportCreateView.as_view(), name='report-create'),
    path('reports/', ReportListView.as_view(), name='report-list'),
    path('dashboard/', DashboardView.as_view(), name='dashboard'),
    path('export/', ExportReportsView.as_view(), name='export-reports'),
    path('confirm/<int:pk>/', ConfirmReportView.as_view(), name='confirm-report'),
    path('sms-callback/', africastalking_sms_callback, name='sms-callback'),
    path('sitrep/<int:pk>/', SitrepPDFView.as_view(), name='sitrep-pdf'),
]
