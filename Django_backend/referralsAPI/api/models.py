from django.db import models

class Referral(models.Model):
	url_string = models.CharField(max_length = 50)
	count = models.IntegerField(default = 0)
