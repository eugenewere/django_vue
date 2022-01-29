from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path, include

from Djackets import settings

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/', include('djoser.urls')),
    path('api/v1/', include('djoser.urls.authtoken')),
    path('api/v1/', include('product.urls')),


]+ static(settings.STATIC_URL, document_root=settings.STATIC_URL)
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)