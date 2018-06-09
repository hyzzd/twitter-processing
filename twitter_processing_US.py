# Import the necessary package to process data in JSON format
try:
    import json
except ImportError:
    import simplejson as json
import numpy as np
import langid
import matplotlib.pyplot as plt

# We use the file saved from last step as example
tweets_filename = 'twitter_stream_10000tweets_US.txt'
tweets_file = open(tweets_filename, "r")
count = 0 # Count number of langid
numbr = 0 # Total number of tweets
geotg = 0 # Total number of geotag
#geoList = {}
langList = {}
langidList = {}

for line in tweets_file:
    try:
        # Read in one line of the file, convert it into a json object
        tweet = json.loads(line.strip())
        if 'text' in tweet: # only messages contains 'text' field is a tweet
            '''            
            print tweet['id'] # This is the tweet's id
            print tweet['created_at'] # when the tweet posted
            print tweet['text'] # content of the tweet
        
            print tweet['user']['id'] # id of the user who posted the tweet
            print tweet['user']['name'] # name of the user, e.g. "Wei Xu"
            print tweet['user']['screen_name'] # name of the user account, e.g. "cocoweixu"

            hashtags = []
            for hashtag in tweet['entities']['hashtags']:
            	hashtags.append(hashtag['text'])
            print hashtags
            '''
            numbr += 1
            if tweet['lang'] != 'und': # Count tweet's langid
                #print tweet['lang']
                #print langid.classify(tweet['lang'])[0] # Tuples
                count += 1
                if tweet['lang'] in langList.keys():
                    langList[tweet['lang']] += 1
                else:
                    langList[tweet['lang']] = 1

            if langid.classify(tweet['text'])[0] in langidList.keys(): # Count langid.py
                langidList[langid.classify(tweet['text'])[0]] += 1
            else:
                langidList[langid.classify(tweet['text'])[0]] = 1

            if tweet['geo'] != None or tweet['coordinates'] != None: # Count geotag tweets
                #print tweet['geo']
                #print tweet['coordinates']
                geotg += 1
                '''
                if tweet['place']['country_code'] in geoList.keys():
                    geoList[tweet['place']['country_code']] += 1
                else:
                    geoList[tweet['place']['country_code']] = 1
                '''
            
    except:
        # read in a line is not in JSON format (sometimes error occured)
        print "This is not in JSON format! (some error might occured)" # needs JSON format
        #print line
        continue

p = np.array(langList.values()) # what % is each language
p = 1.0 * p / numbr # p.sum()

pid = np.array(langidList.values())
pid = 1.0 * pid / numbr

ptg = 100.0 * geotg / numbr

print "**************** Conclusions ****************"
print "The percentage of LangID tagged by Twitter is: %f%s." % (100.0 * count/numbr,'%') # Need .0 to calculate percentage
print "The language list is: %s." % json.dumps(langList)
print "The number of different languages tagged by Twitter is: %d." % len(langList)
print "The percentage is: %s." % p
print "The percentage of LangID tagged by langid.py is: %f%s." % (100.0 * pid.sum(), '%') # Need .0 to calculate percentage
print "The language list is: %s." % json.dumps(langidList)
print "The number of different languages tagged by langid.py is: %d." % len(langidList)
print "The percentage is: %s." % pid
print "The percentage of geotagged tweets is: %f%s." % (ptg, '%')

#print len(langList)
#print json.dumps(langList.keys())
# coordinates, geo(deprecated NULLABLE use coordinate instead), place/country/country_code(associated but not orginate)
# geo_enabled is not because it's in users' profile, id // geolocated tweets or users' location field // woeIDofUS 23424977
print "**************** Plot Figures ****************"

t1 = np.arange(1, len(langList) + 1, 1)
t2 = np.arange(1, len(langidList) + 1, 1)

plt.figure(1)
plt.plot(t1, sorted(langList.values(), reverse=True), 'ro')
plt.annotate('English', xy=(1, 8586), xytext=(5, 8586), arrowprops=dict(facecolor='black', shrink=0.05))
plt.annotate('Haitian', xy=(3, 35), xytext=(8, 335), arrowprops=dict(facecolor='black', shrink=0.05))
plt.annotate('Spanish', xy=(2, 139), xytext=(5, 639), arrowprops=dict(facecolor='black', shrink=0.05))
#plt.annotate('Japanese', xy=(4, 637), xytext=(8, 637), arrowprops=dict(facecolor='black', shrink=0.05))
#plt.annotate('Portuguese', xy=(5, 585), xytext=(5, 385), arrowprops=dict(facecolor='black', shrink=0.05))
#plt.annotate('Turkish', xy=(6, 562), xytext=(10, 562), arrowprops=dict(facecolor='black', shrink=0.05))
#plt.annotate('French', xy=(7, 277), xytext=(11, 277), arrowprops=dict(facecolor='black', shrink=0.05))
plt.xlabel('Languages')
plt.ylabel('Tweets')
#plt.xticks(t1, slangList.keys())
#plt.axis(-10, 20, 0, 0.3)
#plt.xlim(-2,20)
plt.show()

plt.figure(2)
plt.plot(t2, sorted(langidList.values(), reverse=True), 'ro')
plt.annotate('English', xy=(1, 7990), xytext=(10, 7590), arrowprops=dict(facecolor='black', shrink=0.05))
plt.annotate('Chinese', xy=(2, 223), xytext=(6, 723), arrowprops=dict(facecolor='black', shrink=0.05))
plt.annotate('Spanish', xy=(3, 179), xytext=(15, 379), arrowprops=dict(facecolor='black', shrink=0.05))
#plt.annotate('Japanese', xy=(4, 629), xytext=(12, 629), arrowprops=dict(facecolor='black', shrink=0.05))
#plt.annotate('Turkish', xy=(5, 526), xytext=(5, 326), arrowprops=dict(facecolor='black', shrink=0.05))
#plt.annotate('Portuguese', xy=(6, 478), xytext=(14, 478), arrowprops=dict(facecolor='black', shrink=0.05))
#plt.annotate('French', xy=(7, 294), xytext=(15, 294), arrowprops=dict(facecolor='black', shrink=0.05))
plt.xlabel('Languages')
plt.ylabel('Tweets')
#plt.xticks(t2, slangidList.keys())
#plt.axis(-10, 20, 0, 0.3)
#plt.xlim(-2,20)
plt.show()

plt.figure(3)
#plt.plot(sorted(100.0 * p, reverse=True), t1, '^')
plt.subplot(121)
plt.plot(100.0 * p, t1, '^')
plt.hlines(t1, [0], 100.0 * p, lw=2)
plt.xlabel('Percentage/%')
#plt.text(-2, -2, json.dumps(langList.keys()))
plt.yticks(t1, langList.keys())
plt.title('Language share of countries')
#plt.show()

#plt.figure(4)
#plt.plot(sorted(100.0 * p, reverse=True), t1, '^')
plt.subplot(122)
plt.plot(100.0 * pid, t2, '^')
plt.hlines(t2, [0], 100.0 * pid, lw=2)
plt.xlabel('Percentage/%')
#plt.text(-2, -2, json.dumps(langList.keys()))
plt.yticks(t2, langidList.keys())
plt.title('Language share of countries')
plt.show()
