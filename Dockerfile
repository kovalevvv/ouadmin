FROM ruby:2.6

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y nodejs yarn supervisor nginx nano \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir /ouadmin
WORKDIR /ouadmin

COPY Gemfile /ouadmin/Gemfile
RUN bundle install -j $(nproc) --without development test
COPY . /ouadmin
RUN yarn install
RUN EDITOR=/dev/null bundle exec rails credentials:edit > /dev/null 2>&1
RUN rm -f /etc/nginx/sites-enabled/default \
	&& cp nginx-ouadmin.conf /etc/nginx/sites-enabled/ouadmin.conf \
	&& mkdir /etc/nginx/ssl/ && cp ouadmin.key /etc/nginx/ssl/ && cp ouadmin.crt /etc/nginx/ssl/

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 443/tcp 80/tcp
CMD ["app:start"]