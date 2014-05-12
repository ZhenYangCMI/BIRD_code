word = []

fi=open('acquisition.txt', 'r')
for row in fi:
	#print row
	word=str(row)

word=word.split(' ')

#print word


fo=open('acquisition_new.txt', 'w')
for item in word:
	#print item, '\n'
	fo.write(str(item)+'\\n\n')
fo.close
