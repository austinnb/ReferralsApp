from django.conf.urls import patterns, url

urlpatterns = patterns(
	'api.views',
	url(r'^referrals/$', 'referrals_list', name='referrals_list'),
	url(r'^referrals/(?P<pk>[0-9]+)$', 'referrals_detail', name='referrals_detail'),
)
