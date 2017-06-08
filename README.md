# AD REFORM GENDER CLASSIFIER

### INSTALLING

- Create role in postgres:
```
create role ad_reform with createdb login password 'ad_reform';
```
- Download and install app: 
```
git clone git@github.com:elpassion/ad-reform-interview.git && cd ad-reform-interview && bundle && rails db:setup && echo "Ad Reform Gender Classifier is ready to work :)"
```

### TESTING

`bundle exec rspec`
