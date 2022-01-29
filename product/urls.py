
from django.contrib import admin
from django.urls import path, include

from product.views import LatestProductsList

urlpatterns = [
    path('latest_products/', LatestProductsList.as_view())
]
