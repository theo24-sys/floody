import csv
from django.http import HttpResponse
from django.template.loader import render_to_string
from weasyprint import HTML
from .models import FloodReport

def export_reports_to_csv(queryset):
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="flood_reports.csv"'

    writer = csv.writer(response)
    writer.writerow(['ID', 'Device ID', 'Lat', 'Lng', 'Category', 'Status', 'Is Manual', 'Timestamp'])

    for report in queryset:
        writer.writerow([
            report.id,
            report.device_id,
            report.location.y,
            report.location.x,
            report.category,
            report.status,
            report.is_manual,
            report.timestamp,
        ])

    return response

def generate_sitrep_pdf(report_id):
    report = FloodReport.objects.get(id=report_id)
    html_string = render_to_string('reports/sitrep_template.html', {'report': report})
    html = HTML(string=html_string)
    pdf = html.write_pdf()
    
    response = HttpResponse(pdf, content_type='application/pdf')
    response['Content-Disposition'] = f'attachment; filename="SITREP_{report.id}.pdf"'
    return response
