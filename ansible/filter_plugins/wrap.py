# Wrap a list in quotes.
# @see https://stackoverflow.com/questions/29537684/add-quotes-to-elemens-of-the-list-in-jinja2-ansible

def wrap(list):
  return [ "'" + x + "'" for x in list]

class FilterModule(object):
  def filters(self):
    return {
      'wrap': wrap
    }
