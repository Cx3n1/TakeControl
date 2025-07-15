class_name Utils


static func check_if_on_layer(body, layer_name):
    return body.collision_layer & (1 << Enums.collision[layer_name]) == (1 << Enums.collision[layer_name])


## formats numbers into shorthand notation
## aka 1000 -> 1k, 1,000,000 -> 1M etc.
## supports numbers up to billin
static func format_shorthand(amount : int):
    var number_string = str(amount);
    
    # doubt anyone will have more than 1000 billion coins
    if amount > 9_999_999_999:
        number_string = str(amount/1_000_000_000) + "B"
    elif amount > 999_999_999:
        number_string = str(amount/1_000_000_000) + "." + str((amount%1_000_000_000)/100_000_000) + "B"
    elif amount > 9_999_999:
        number_string = str(amount/1_000_000) + "M"
    elif amount > 999_999:
        number_string = str(amount/1_000_000) + "." + str((amount%1_000_000)/100_000) + "M"
    elif amount > 9999:
        number_string = str(amount/1000) + "k"
    elif amount > 999:
        number_string = str(amount/1000) + "." + str((amount%1000)/100) + "k"

    
    return number_string
