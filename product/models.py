from io import BytesIO

from PIL import Image
from django.core.files import File
from django.db import models


# Create your models here.
class TimestampModel(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True


class Category(TimestampModel):
    name = models.CharField(max_length=255)
    slug = models.SlugField()

    class Meta:
        ordering = ('name',)
        db_table = 'category'

    def __str__(self):
        return self.name

    @property
    def get_absolute_url(self):
        return f'/{self.slug}/'


class Product(TimestampModel):
    category = models.ForeignKey(Category, on_delete=models.CASCADE, null=False, related_name='product_set')
    name = models.CharField(max_length=255)
    slug = models.SlugField()
    description = models.TextField()
    price = models.DecimalField(max_digits=6, decimal_places=2)
    image = models.ImageField(upload_to='uploads/', blank=True, null=True)
    thumbnail = models.ImageField(upload_to='uploads/', blank=True, null=True)

    class Meta:
        ordering = ('-created_at',)
        db_table = 'product'

    def __str__(self):
        return self.name

    @property
    def get_absolute_url(self):
        return f'/{self.category.slug}/{self.slug}/'


    def get_image(self):
        if self.image:
            return self.image.url
        return ''


    def get_thumbnail(self):
        if self.thumbnail:
            return self.thumbnail.url
        else:
            if self.image:
                self.thumbnail = self.make_thumbnail(self.image)
                self.save()
                return self.thumbnail.url
            return ''

    def make_thumbnail(self, image, size=(300, 200)):
        img = Image.open(image)
        img.convert('RGB')
        img.thumbnail(size)
        thumb_io = BytesIO()
        img.save(thumb_io, 'JPEG', quality=85)

        thumbnail = File(thumb_io, name=image.name)
        return thumbnail
















