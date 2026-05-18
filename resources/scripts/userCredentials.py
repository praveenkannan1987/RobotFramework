import yaml

def getCredForProfileYaml(fileName, env, profile_type):
    with open(fileName, 'r') as file:
        try:
            data = yaml.safe_load(file)
        except yaml.YAMLError as exc:
            return exc
    user_data = data.get(env, {}).get(profile_type,{})
    secure_token = data.get(env,{}).get('SECURE_TOKEN')

    return {
        'USERNAME': user_data.get('USERNAME'),
        'PWD': user_data.get('PWD'),
        'SECURE_TOKEN': secure_token
    }