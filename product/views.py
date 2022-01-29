from django.shortcuts import render

# Create your views here.
from rest_framework.response import Response
from rest_framework.views import APIView

from product.models import Product
from product.serialisers import ProductSerialiser


class LatestProductsList(APIView):
    def get(self, request, format=None):
        products = Product.objects.all()[0:5]
        serializer = ProductSerialiser(products, many=True, context={'request': request})
        return Response(serializer.data)