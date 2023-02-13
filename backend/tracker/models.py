from django.db import models
#from django.contrib.gis.db import models as models2
from django.contrib.auth.models import User


class Journey(models.Model):

    user = models.ForeignKey(User, on_delete=models.CASCADE)

    name = models.CharField(max_length=100, blank=True, default='')
    description = models.CharField(max_length=1000, blank=True, default='')
    created = models.DateTimeField(auto_now_add=True)
    ended_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        ordering = ['created']


class Movement(models.Model):

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    journey = models.ForeignKey(Journey, on_delete=models.CASCADE, null=True, blank=True)

    created = models.DateTimeField(auto_now_add=True)
    ended_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        ordering = ['created']

class Point(models.Model):

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    movement = models.ForeignKey(Movement, on_delete=models.CASCADE)

    created = models.DateTimeField(auto_now_add=True)
    lon = models.FloatField(blank=False)
    lat = models.FloatField(blank=False)

    class Meta:
        ordering = ['created']