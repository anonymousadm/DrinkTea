import os
import subprocess
from flask import Flask, render_template, request, url_for
from requests_oauthlib import OAuth1Session
import oauth2
import urllib.request
import urllib.parse
import urllib.error
import json

app = Flask(__name__)

app.debug = False
#app.debug = True

request_token_url = 'https://api.twitter.com/oauth/request_token'
access_token_url = 'https://api.twitter.com/oauth/access_token'
authorize_url = 'https://api.twitter.com/oauth/authorize'
show_user_url = 'https://api.twitter.com/1.1/users/show.json'

# Support keys from environment vars (Heroku).
app.config['APP_CONSUMER_KEY'] = os.getenv('TWAUTH_APP_CONSUMER_KEY', 'API_Key_from_Twitter')
app.config['APP_CONSUMER_SECRET'] = os.getenv('TWAUTH_APP_CONSUMER_SECRET', 'API_Secret_from_Twitter')

# alternatively, add your key and secret to config.cfg
# config.cfg should look like:
# APP_CONSUMER_KEY = 'API_Key_from_Twitter'
# APP_CONSUMER_SECRET = 'API_Secret_from_Twitter'
app.config.from_pyfile('config.cfg', silent=True)

oauth_store = {}


@app.route('/')
def start():
    # note that the external callback URL must be added to the whitelist on
    # the developer.twitter.com portal, inside the app settings
    app_callback_url = url_for('callback', _external=True)

    # Generate the OAuth request tokens, then display them
    consumer = oauth2.Consumer(app.config['APP_CONSUMER_KEY'], app.config['APP_CONSUMER_SECRET'])
    client = oauth2.Client(consumer)
    tumblr = OAuth1Session(app.config['APP_CONSUMER_KEY'], client_secret=app.config['APP_CONSUMER_SECRET'], callback_uri=app_callback_url)
    content = tumblr.fetch_request_token(request_token_url)

    oauth_token = content['oauth_token']
    oauth_token_secret = content['oauth_token_secret']

    oauth_store[oauth_token] = oauth_token_secret
    return render_template('index.html', authorize_url=authorize_url, oauth_token=oauth_token, request_token_url=request_token_url)


@app.route('/callback')
def callback():
    # Accept the callback params, get the token and call the API to
    # display the logged-in user's name and handle
    oauth_token = request.args.get('oauth_token')
    oauth_verifier = request.args.get('oauth_verifier')
    oauth_denied = request.args.get('denied')

    # if the OAuth request was denied, delete our local token
    # and show an error message
    if oauth_denied:
        if oauth_denied in oauth_store:
            del oauth_store[oauth_denied]
        return render_template('error.html', error_message="the OAuth request was denied by this user")

    if not oauth_token or not oauth_verifier:
        return render_template('error.html', error_message="callback param(s) missing")

    # unless oauth_token is still stored locally, return error
    if oauth_token not in oauth_store:
        return render_template('error.html', error_message="oauth_token not found locally")

    oauth_token_secret = oauth_store[oauth_token]

    # if we got this far, we have both callback params and we have
    # found this token locally

    consumer = oauth2.Consumer(app.config['APP_CONSUMER_KEY'], app.config['APP_CONSUMER_SECRET'])
    token = oauth2.Token(oauth_token, oauth_token_secret)
    token.set_verifier(oauth_verifier)
    client = oauth2.Client(consumer, token)

    oauth = OAuth1Session(app.config['APP_CONSUMER_KEY'],
                          client_secret=app.config['APP_CONSUMER_SECRET'],
                          resource_owner_key=oauth_token,
                          resource_owner_secret=oauth_token_secret,
                          verifier=oauth_verifier)
    oauth_tokens = oauth.fetch_access_token(access_token_url)

    global screen_name
    screen_name = oauth_tokens['screen_name']
    user_id = oauth_tokens['user_id']

    # These are the tokens you would store long term, someplace safe
    real_oauth_token = oauth_tokens['oauth_token']
    real_oauth_token_secret = oauth_tokens['oauth_token_secret']

    # Call api.twitter.com/1.1/users/show.json?user_id={user_id}
    
    real_token = oauth2.Token(real_oauth_token, real_oauth_token_secret)
    real_client = oauth2.Client(consumer, real_token)

    # Add authentication token into .twurlrc
    consumer_key = app.config['APP_CONSUMER_KEY']
    consumer_secret = app.config['APP_CONSUMER_SECRET']
    file = '/home/ubuntu/.twurlrc'
    new_content = []
    with open(file, 'r') as in_file:
        for line in in_file.readlines():
            if screen_name in line:
                print("{} has already registered".format(screen_name))
                
            elif "configuration:" in line:
                new_content += "  {}:".format(screen_name)
                new_content += "\n"
                new_content += "    {}:".format(consumer_key)
                new_content += "\n"
                new_content += "      username: {}".format(screen_name)
                new_content += "\n"
                new_content += "      consumer_key: {}".format(consumer_key)
                new_content += "\n"
                new_content += "      consumer_secret: {}".format(consumer_secret)
                new_content += "\n"
                new_content += "      token: {}".format(real_oauth_token)
                new_content += "\n"
                new_content += "      secret: {}".format(real_oauth_token_secret)
                new_content += "\n"
            new_content += line
    with open(file, 'w') as out_file:
        out_file.writelines(new_content)
    in_file.close()
    out_file.close()

    # Get user's status
    statuses_out = subprocess.Popen(['/var/DrinkTea/statuses.sh', screen_name], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout,stderr = statuses_out.communicate()
    statuses = (stdout.decode('utf-8')).splitlines()
    #print(statuses_out.stdout.read())

    # don't keep this token and secret in memory any longer
    del oauth_store[oauth_token]

    return render_template('callback-success.html', screen_name=screen_name, statuses_count=statuses[0], followers_count=statuses[1], friends_count=statuses[2], block_count=statuses[3], mute_count=statuses[4])


@app.route('/drinktea')
def drinktea():
    statuses_out = subprocess.Popen(['/var/DrinkTea/DrinkTea.sh', screen_name], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout,stderr = statuses_out.communicate()
    QRcode = (stdout.decode('utf-8'))
    return render_template('drinktea.html', screen_name=screen_name, QRcode=QRcode)


@app.errorhandler(500)
def internal_server_error(e):
    return render_template('error.html', error_message='uncaught exception'), 500

  
if __name__ == '__main__':
    app.run(host='0.0.0.0')
    #app.run(host='0.0.0.0', ssl_context=('/var/DrinkTea/cert.pem', '/var/DrinkTea/key.pem'))
