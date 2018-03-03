module Types(
    State(..), Reader(..), Writer(..),
    runState, runWriter, runReader,
    module Control.Applicative,
    module Control.Monad,
    module Data.Monoid)    
where

import Data.Monoid
import Control.Applicative
import Control.Monad

-------------------------------------------------

-- class Functor f where
--     fmap :: (a -> b) -> f a -> f b
-- 
-- class Functor f => Applicative f where
--     pure    :: a -> f a
--     (<*>)   :: f (a -> b) -> f a -> f b
-- 
-- class Monad m where
--     return  :: a -> m a
--     (>>=)   :: m a -> (a -> m b) -> m b
-- 
-- (=<<) :: (a -> m b) -> m a -> m b
-- (=<<) = flip (>>=)

-- Композиция
-- (>=>) :: Monad m => (a -> m b) -> (b -> m c) -> (a -> m c)
-- (<=<) :: Monad m => (b -> m c) -> (a -> m b) -> (a -> m c)

-- Константные функции
-- (*>) :: Applicative f => f a -> f b -> f b
-- (<*) :: Applicative f => f a -> f b -> f a

-- Применение обычных функций к специальным значениям
-- (<$>)  :: Functor f => (a -> b) -> f a -> f b

-- liftA  :: Applicative f => (a -> b)           -> f a -> f b
-- liftA2 :: Applicative f => (a -> b -> c)      -> f a -> f b -> f c
-- liftA3 :: Applicative f => (a -> b -> c -> d) -> f a -> f b -> f c -> f d

-- Преобразование элементов списка специальной функцией
-- mapM   :: Monad m => (a -> m b) -> [a] -> m [b]

-------------------------------------------------
-- Функции с состоянием
--
--      a -> State s b

data State s a = State (s -> (a, s))

runState :: State s a -> s -> (a, s)
runState (State f) = f

instance Monad (State s) where
    return a  = State $ \s -> (a, s)
    ma >>= mf = State $ \s0 -> 
                    let (b, s1) = runState ma s0
                    in   runState (mf b) s1

instance Applicative (State s) where
    pure = return
    mf <*> ma = State $ \s -> 
        let (a, s') = runState ma s
            (f, s'') = runState mf s'
        in ((f a), s'')

instance Functor (State s) where
    fmap f ma = State $ \s ->
                let (a, s') = runState ma s
                in ((f a), s')

---------------------------------------------------
-- Функции с окружением
--
--      a -> Reader env b

data Reader env a = Reader (env -> a)

runReader :: Reader env a -> env -> a
runReader (Reader f) = f

instance Monad (Reader env) where
    return a    = Reader $ const a
    ma >>= mf   = Reader $ \env ->
        let b = runReader ma env
        in runReader (mf b) env 

instance Applicative (Reader env) where
    pure = return
    mf <*> ma = Reader $ \env ->
        let a = runReader ma env
            f = runReader mf env
        in (f a)

instance Functor (Reader env) where
    fmap f ma = Reader $ \env ->
                let a = runReader ma env
                in (f a)

---------------------------------------------------
-- Функции-накопители
--
--      Monoid msg => a -> Writer msg b

data Writer msg a = Writer (a, msg)
    deriving (Show)

runWriter :: Writer msg a -> (a, msg)
runWriter (Writer f) = f

instance Monoid msg => Monad (Writer msg) where
    return a    = Writer (a, mempty)
    ma >>= mf   = Writer (c, msgA `mappend` msgF)
        where (b, msgA) = runWriter ma
              (c, msgF) = runWriter $ mf b

instance Monoid msg => Applicative (Writer msg) where
    pure = return
    mf <*> ma = case (runWriter mf) of
        (f, msgF) -> case (runWriter ma) of
            (a, msgA) -> Writer (f a, msgA `mappend` msgF)

instance Monoid msg => Functor (Writer msg) where
    fmap f ma = case (runWriter ma) of
        (a, msgA) -> Writer (f a, mempty `mappend` msgA)
  
---------------------------------------------------
