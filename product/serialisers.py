from rest_framework import serializers

from product.models import Product


class ProductSerialiser(serializers.ModelSerializer):
    image = serializers.SerializerMethodField()
    thumbnail = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields =(
            'id',
            'name',
            'get_absolute_url',
            'description',
            'price',
            'image',
            'thumbnail',
            'created_at',
            'updated_at'
        )

    def get_image(self, product):
        request = self.context.get('request')
        main_image = product.image.url
        return request.build_absolute_uri(main_image)

    def get_thumbnail(self, product):
        request = self.context.get('request')
        main_image = product.thumbnail.url
        return request.build_absolute_uri(main_image)