defmodule MyStream do 
    import Creek 

    # keypresses :: (1, 1)
    defdag keypresses 
           filter(&letters_key/1)
           ~> map(&keypress_to_human_readable/1)

    # current_time :: (1, 1)       
    defdag current_time
           map(&epoch_to_datetime/1)

    # logkeys :: (2, 1)       
    defdag logkeys 
           zip()

    # logger   :: (2, 1)
    # key_src  :: (0, 1) 
    # time_src :: (0, 1)
    # db_sink  :: (1, 0) 
    defdag logger(key_src, time_src, db_snk) do

              # left :: (0, 1)
              let left  = key_src 
                          ~> keypresses
              # right :: (0, 1)        
              let right = time_src 
                          ~> current_time 
              # bottom :: (2, 1)
              let bottom = log_keys 

              left  >> bottom 
              right >> bottom
              bottom >> db_snk 

              bottom / left / right / ?
    end
end  

#########

# Assume there is a global stream process 
defmodule Desugared do
  def events() do
    eventlist = [
      {:define, :keypresses,
       [
         {:instantiate_operator, :filter, &letters_key/1},
         {:instantiate_operator, :map, &keypress_to_human_readable/1},
         {:link, op1, op2}
       ]},
      {:define, :current_time,
       [
         {:instantiate_operator, :map, &epoch_to_datetime/1}
       ]}
    ]
  end
end
