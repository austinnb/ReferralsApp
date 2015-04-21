from django.shortcuts import render

from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from api.models import Referral
from api.serializers import ReferralSerializer

@api_view(['GET', 'POST'])
def referrals_list(request):
	if request.method == 'GET':
		referrals = Referral.objects.all()
		serializer = ReferralSerializer(referrals, many = True)
		return Response(serializer.data)
	elif request.method == 'POST':
		serializer = ReferralSerializer(data=request.DATA)
		if serializer.is_valid():
			serializer.save()
			return Response(serializer.data, status=status.HTTP_201_CREATED)
		else:
			return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET','PUT','DELETE'])
def referrals_detail(request, pk):
	try: 
		referral = Referral.objects.get(pk=pk)
	except:
		return Response(status=status.HTTP_404_NOT_FOUND)

	if request.method == 'GET':
		serializer = ReferralSerializer(referral)
		return Response(serializer.data)
	elif request.method == 'PUT':
		serializer = ReferralSerializer(referral, data=request.DATA)
		if serializer.is_valid():
			serializer.save()
			return Response(serializer.data)
		else:
			return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
	elif request.method == 'DELETE':
		referral.delete()
		return Response(staus=staus.HTTP_204_NO_CONTENT)

