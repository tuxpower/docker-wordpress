deploy:
				docker-compose up -d

clean:
				docker stop $(docker ps -q) && docker rm $(docker ps -qa)
